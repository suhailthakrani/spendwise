import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../models/backup_snapshot.dart';
import 'google_auth_service.dart';

class DriveBackupException implements Exception {
  DriveBackupException(this.message, {this.signInUnavailable = false});
  final String message;
  final bool signInUnavailable;

  @override
  String toString() => message;
}

class DriveBackupResult {
  const DriveBackupResult({
    required this.fileId,
    required this.email,
  });

  final String fileId;
  final String email;
}

/// Uploads / downloads one SpendWise backup on the signed-in Google Drive.
class GoogleDriveBackupClient {
  GoogleDriveBackupClient({GoogleSignIn? signIn}) : _injected = signIn;

  static const _scopes = [
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ];
  static const _fileName = 'spendwise_backup.json';
  static const _folderName = 'SpendWise Backups';
  static const _mimeJson = 'application/json';
  static const _mimeFolder = 'application/vnd.google-apps.folder';

  final GoogleSignIn? _injected;
  GoogleSignIn? _signIn;

  GoogleSignIn get _client {
    return _injected ??
        (_signIn ??= GoogleSignIn(
          scopes: _scopes,
          serverClientId: GoogleAuthService.serverClientId,
        ));
  }

  /// Opens the Google account picker and returns the chosen Drive email.
  Future<String> connectAccount({String? preferEmail}) async {
    try {
      final preferred = preferEmail?.trim().toLowerCase();
      var account = _client.currentUser ?? await _client.signInSilently();
      if (account != null &&
          preferred != null &&
          preferred.isNotEmpty &&
          account.email.trim().toLowerCase() != preferred) {
        await _client.signOut();
        account = null;
      }
      account ??= await _client.signIn();
      if (account == null) {
        throw DriveBackupException('Google sign-in was cancelled');
      }
      final granted = await _client.requestScopes(_scopes);
      if (!granted) {
        throw DriveBackupException(
          'Allow Drive access to save the SpendWise backup.',
        );
      }
      return account.email.trim().toLowerCase();
    } on DriveBackupException {
      rethrow;
    } catch (error) {
      throw DriveBackupException(
        _humanize(error),
        signInUnavailable: _isSignInMisconfigured(error),
      );
    }
  }

  Future<String> connectAndVerifyEmail(String expectedEmail) {
    return connectAccount(preferEmail: expectedEmail);
  }

  Future<DriveBackupResult> upload({
    required BackupSnapshot snapshot,
    required String expectedEmail,
    String? existingFileId,
  }) async {
    final email = await connectAccount(preferEmail: expectedEmail);
    final api = await _driveApi();
    final bytes = utf8.encode(jsonEncode(snapshot.toJson()));
    drive.Media media() => drive.Media(
          Stream<List<int>>.fromIterable([bytes]),
          bytes.length,
          contentType: _mimeJson,
        );

    var fileId = existingFileId;
    if (fileId != null && fileId.isNotEmpty) {
      try {
        final updated = await api.files.update(
          drive.File()..name = _fileName,
          fileId,
          uploadMedia: media(),
        );
        return DriveBackupResult(fileId: updated.id ?? fileId, email: email);
      } catch (_) {
        fileId = null;
      }
    }

    final folderId = await _ensureFolder(api);
    fileId = await _findBackupFileId(api, folderId);
    if (fileId != null) {
      final updated = await api.files.update(
        drive.File()..name = _fileName,
        fileId,
        uploadMedia: media(),
      );
      return DriveBackupResult(fileId: updated.id ?? fileId, email: email);
    }

    final created = await api.files.create(
      drive.File()
        ..name = _fileName
        ..parents = [folderId],
      uploadMedia: media(),
    );
    if (created.id == null || created.id!.isEmpty) {
      throw DriveBackupException('Google Drive did not return a file id');
    }
    return DriveBackupResult(fileId: created.id!, email: email);
  }

  Future<BackupSnapshot> download({
    required String expectedEmail,
    String? fileId,
  }) async {
    await connectAccount(preferEmail: expectedEmail);
    final api = await _driveApi();
    var id = fileId;
    if (id == null || id.isEmpty) {
      final folderId = await _findFolderId(api);
      if (folderId == null) {
        throw DriveBackupException('No SpendWise backup found on this Drive');
      }
      id = await _findBackupFileId(api, folderId);
    }
    if (id == null || id.isEmpty) {
      throw DriveBackupException('No SpendWise backup found on this Drive');
    }

    final media = await api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (media is! drive.Media) {
      throw DriveBackupException('Could not download the backup file');
    }

    final chunks = <int>[];
    await for (final chunk in media.stream) {
      chunks.addAll(chunk);
    }
    final decoded = jsonDecode(utf8.decode(chunks));
    if (decoded is! Map) {
      throw DriveBackupException('Backup file is not valid JSON');
    }
    return BackupSnapshot.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<drive.DriveApi> _driveApi() async {
    final account = _client.currentUser;
    if (account == null) {
      throw DriveBackupException('Not signed in to Google');
    }
    final headers = await account.authHeaders;
    return drive.DriveApi(_AuthedClient(headers));
  }

  Future<String> _ensureFolder(drive.DriveApi api) async {
    final existing = await _findFolderId(api);
    if (existing != null) return existing;
    final created = await api.files.create(
      drive.File()
        ..name = _folderName
        ..mimeType = _mimeFolder,
    );
    if (created.id == null) {
      throw DriveBackupException('Could not create a Drive folder');
    }
    return created.id!;
  }

  Future<String?> _findFolderId(drive.DriveApi api) async {
    final result = await api.files.list(
      q: "name = '$_folderName' and mimeType = '$_mimeFolder' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    final files = result.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }

  Future<String?> _findBackupFileId(drive.DriveApi api, String folderId) async {
    final result = await api.files.list(
      q: "name = '$_fileName' and '$folderId' in parents and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    final files = result.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }

  static bool _isSignInMisconfigured(Object error) {
    final text = error is PlatformException
        ? '${error.code} ${error.message ?? ''}'
        : error.toString();
    final lower = text.toLowerCase();
    return lower.contains('channel-error') ||
        lower.contains('unable to establish connection') ||
        lower.contains('10:') ||
        lower.contains('developer_error') ||
        lower.contains('api_not_connected');
  }

  static String _humanize(Object error) {
    final text = error is PlatformException
        ? '${error.code} ${error.message ?? ''}'
        : error.toString();
    final lower = text.toLowerCase();
    if (lower.contains('channel-error') ||
        lower.contains('unable to establish connection')) {
      return 'Google Drive is not available in this build. Stop the app and '
          'run it again with a full restart (not hot reload).';
    }
    if (lower.contains('network_error') || lower.contains('network')) {
      return 'Check your internet connection and try again.';
    }
    if (lower.contains('sign_in_canceled') || lower.contains('canceled')) {
      return 'Google sign-in was cancelled';
    }
    if (lower.contains('10:') ||
        lower.contains('developer_error') ||
        lower.contains('api_not_connected')) {
      return 'Google Sign-In is not enabled for this Firebase project yet. '
          'Enable Google in Authentication, download a new google-services.json, '
          'and fully restart the app.';
    }
    debugPrint('Google Drive error: $error');
    return 'Could not open Google Drive. Try again.';
  }
}

class _AuthedClient extends http.BaseClient {
  _AuthedClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

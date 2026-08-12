import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a picked image into app documents for durable local avatars.
abstract final class AvatarStorage {
  static Future<String> saveForUser({
    required String userId,
    required String sourcePath,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'avatars'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final ext = p.extension(sourcePath).toLowerCase();
    final safeExt =
        (ext == '.png' || ext == '.jpg' || ext == '.jpeg' || ext == '.webp')
            ? ext
            : '.jpg';
    final destPath = p.join(dir.path, '$userId$safeExt');

    // Remove any previous avatar files for this user (other extensions).
    await _deleteExisting(dir, userId);

    final source = File(sourcePath);
    final saved = await source.copy(destPath);
    return saved.path;
  }

  static Future<void> deleteForUser(String userId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'avatars'));
    if (!await dir.exists()) return;
    await _deleteExisting(dir, userId);
  }

  static Future<void> _deleteExisting(Directory dir, String userId) async {
    await for (final entity in dir.list()) {
      if (entity is File && p.basename(entity.path).startsWith(userId)) {
        await entity.delete();
      }
    }
  }
}

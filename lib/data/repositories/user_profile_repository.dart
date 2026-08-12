import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_seed.dart';
import '../../core/utils/password_hasher.dart';
import '../mappers/user_profile_mapper.dart';
import '../models/app_currency.dart';
import '../models/app_region.dart';
import '../models/user_profile.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UserProfileRepository {
  UserProfileRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<UserProfile?> watchById(String id) {
    return (_db.select(_db.userProfiles)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : UserProfileMapper.fromRow(row));
  }

  Future<UserProfile?> getById(String id) async {
    final row = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : UserProfileMapper.fromRow(row);
  }

  Future<UserProfile?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final row = await (_db.select(_db.userProfiles)
          ..where((t) => t.email.equals(normalized)))
        .getSingleOrNull();
    return row == null ? null : UserProfileMapper.fromRow(row);
  }

  /// Creates a new local account and seeds starter categories.
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String regionCode,
    required String currencyCode,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw AuthException('Enter your name');
    }
    if (!_isValidEmail(normalizedEmail)) {
      throw AuthException('Enter a valid email');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final region = AppRegion.byCode(regionCode);
    final currency = AppCurrency.byCode(currencyCode);

    final existing = await (_db.select(_db.userProfiles)
          ..where((t) => t.email.equals(normalizedEmail)))
        .getSingleOrNull();
    if (existing != null) {
      throw AuthException('An account with this email already exists');
    }

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final userId = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: userId,
            name: trimmedName,
            email: normalizedEmail,
            passwordHash: Value(hash),
            passwordSalt: Value(salt),
            regionCode: Value(region.code),
            currencyCode: Value(currency.code),
            memberSince: Value(now),
          ),
        );
    await seedCategoriesForUser(_db, userId);

    final profile = await getById(userId);
    if (profile == null) {
      throw AuthException('Could not create account');
    }
    return profile;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final row = await (_db.select(_db.userProfiles)
          ..where((t) => t.email.equals(normalizedEmail)))
        .getSingleOrNull();

    if (row == null ||
        !PasswordHasher.verify(
          password: password,
          salt: row.passwordSalt,
          expectedHash: row.passwordHash,
        )) {
      throw AuthException('Incorrect email or password');
    }

    return UserProfileMapper.fromRow(row);
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw AuthException('Enter your name');
    }
    if (!_isValidEmail(normalizedEmail)) {
      throw AuthException('Enter a valid email');
    }

    final row = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
    if (row == null) {
      throw AuthException('Profile not found');
    }

    if (normalizedEmail != row.email) {
      final taken = await (_db.select(_db.userProfiles)
            ..where((t) => t.email.equals(normalizedEmail)))
          .getSingleOrNull();
      if (taken != null) {
        throw AuthException('An account with this email already exists');
      }
    }

    var hash = row.passwordHash;
    var salt = row.passwordSalt;
    final wantsPasswordChange =
        newPassword != null && newPassword.trim().isNotEmpty;
    if (wantsPasswordChange) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw AuthException('Enter your current password');
      }
      if (!PasswordHasher.verify(
        password: currentPassword,
        salt: row.passwordSalt,
        expectedHash: row.passwordHash,
      )) {
        throw AuthException('Current password is incorrect');
      }
      if (newPassword.length < 6) {
        throw AuthException('New password must be at least 6 characters');
      }
      salt = PasswordHasher.generateSalt();
      hash = PasswordHasher.hash(newPassword, salt);
    }

    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(userId)))
        .write(
      UserProfilesCompanion(
        name: Value(trimmedName),
        email: Value(normalizedEmail),
        passwordHash: Value(hash),
        passwordSalt: Value(salt),
        avatarUrl: clearAvatar
            ? const Value(null)
            : (avatarUrl != null ? Value(avatarUrl) : const Value.absent()),
      ),
    );

    final updated = await getById(userId);
    if (updated == null) {
      throw AuthException('Could not update profile');
    }
    return updated;
  }

  /// Updates country/region only — currency stays independent.
  Future<UserProfile> setRegion({
    required String userId,
    required String regionCode,
  }) async {
    final region = AppRegion.byCode(regionCode);
    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(userId)))
        .write(
      UserProfilesCompanion(regionCode: Value(region.code)),
    );
    final updated = await getById(userId);
    if (updated == null) throw AuthException('Profile not found');
    return updated;
  }

  /// Updates display currency without changing region.
  Future<UserProfile> setCurrency({
    required String userId,
    required String currencyCode,
  }) async {
    final currency = AppCurrency.byCode(currencyCode);
    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(userId)))
        .write(
      UserProfilesCompanion(currencyCode: Value(currency.code)),
    );
    final updated = await getById(userId);
    if (updated == null) throw AuthException('Profile not found');
    return updated;
  }

  /// Verifies password, then permanently deletes this user's local data.
  Future<void> deleteAccount({
    required String userId,
    required String password,
  }) async {
    final row = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
    if (row == null) {
      throw AuthException('Account not found');
    }
    if (!PasswordHasher.verify(
      password: password,
      salt: row.passwordSalt,
      expectedHash: row.passwordHash,
    )) {
      throw AuthException('Incorrect password');
    }

    await _db.transaction(() async {
      await (_db.delete(_db.savingContributions)
            ..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.savingGoals)
            ..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.expenses)..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.budgets)..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.recurringExpenses)
            ..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.categories)..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.userProfiles)..where((t) => t.id.equals(userId)))
          .go();
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}

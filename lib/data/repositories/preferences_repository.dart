import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_seed.dart';
import '../mappers/preferences_mapper.dart';
import '../models/user_preferences.dart';

/// Reads and writes preferences as a single [UserPreferences] view over two
/// tables: device state in `app_preferences`, account settings in
/// `user_settings`. Callers never need to know which table a field lives in.
class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  static const _preferencesId = PreferencesMapper.preferencesId;

  Stream<UserPreferences> watchPreferences() {
    return _query().watchSingleOrNull().map(_merge);
  }

  Future<UserPreferences> getPreferences() async {
    return _merge(await _query().getSingleOrNull());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final userId = await _activeUserId();
    // Mirrored onto the device row so splash and sign-in match the last
    // account's theme before any session exists.
    await _writeDevice(AppPreferencesCompanion(themeMode: Value(mode.name)));
    if (userId != null) {
      await _writeSettings(
        userId,
        UserSettingsCompanion(themeMode: Value(mode.name)),
      );
    }
  }

  Future<void> completeOnboarding() async {
    await _writeDevice(
      const AppPreferencesCompanion(hasCompletedOnboarding: Value(true)),
    );
  }

  Future<void> setActiveUserId(String userId) async {
    await seedSettingsForUser(_db, userId);
    await _writeDevice(AppPreferencesCompanion(activeUserId: Value(userId)));
  }

  Future<void> clearSession() async {
    await _writeDevice(
      const AppPreferencesCompanion(activeUserId: Value(null)),
    );
  }

  Future<void> setBackupDriveEmail(String? email) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    final current = await getPreferences();
    final normalized = email?.trim().toLowerCase();
    final cleared = normalized == null || normalized.isEmpty;
    final emailChanged = (normalized ?? '') != (current.backupDriveEmail ?? '');

    await _writeSettings(
      userId,
      UserSettingsCompanion(
        backupDriveEmail: Value(cleared ? null : normalized),
        // A different Drive account means the remembered file no longer applies.
        backupDriveFileId:
            emailChanged ? const Value(null) : const Value.absent(),
      ),
    );
  }

  Future<void> setLastBackup({
    required DateTime at,
    String? driveFileId,
  }) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(
        lastBackupAt: Value(at),
        backupDriveFileId: Value(
          driveFileId == null || driveFileId.isEmpty ? null : driveFileId,
        ),
      ),
    );
  }

  /// Device-level: one local account can be unlocked by this device's
  /// biometrics, so this deliberately stays out of per-account settings.
  Future<void> setBiometricUnlock({
    required bool enabled,
    String? userId,
  }) async {
    final bound = enabled && userId != null && userId.isNotEmpty;
    await _writeDevice(
      AppPreferencesCompanion(
        biometricUnlockEnabled: Value(bound),
        biometricUserId: Value(bound ? userId : null),
      ),
    );
  }

  Future<void> setNotificationSettings({
    bool? notificationsEnabled,
    bool? billRemindersEnabled,
    bool? budgetAlertsEnabled,
    bool? goalRemindersEnabled,
    bool? productUpdatesEnabled,
  }) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(
        notificationsEnabled: _value(notificationsEnabled),
        billRemindersEnabled: _value(billRemindersEnabled),
        budgetAlertsEnabled: _value(budgetAlertsEnabled),
        goalRemindersEnabled: _value(goalRemindersEnabled),
        productUpdatesEnabled: _value(productUpdatesEnabled),
      ),
    );
  }

  Future<void> setEntryDefaults({
    String? defaultCategoryId,
  }) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(
        defaultCategoryId: Value(defaultCategoryId),
      ),
    );
  }

  Future<void> setLastUsedCategoryId(String? categoryId) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(lastUsedCategoryId: Value(categoryId)),
    );
  }

  Future<void> setDashboardLayoutJson(String json) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(dashboardLayoutJson: Value(json)),
    );
  }

  Future<void> setAnalyticsPeriod(String period) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(analyticsPeriod: Value(period)),
    );
  }

  Future<void> setQuickActionsJson(String json) async {
    final userId = await _activeUserId();
    if (userId == null) return;

    await _writeSettings(
      userId,
      UserSettingsCompanion(quickActionsJson: Value(json)),
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _query() {
    return _db.select(_db.appPreferences).join([
      leftOuterJoin(
        _db.userSettings,
        _db.userSettings.userId.equalsExp(_db.appPreferences.activeUserId),
      ),
    ])
      ..where(_db.appPreferences.id.equals(_preferencesId));
  }

  UserPreferences _merge(TypedResult? result) {
    final device = result?.readTableOrNull(_db.appPreferences);
    if (device == null) return UserPreferences.defaults();
    return PreferencesMapper.fromRows(
      device: device,
      settings: result?.readTableOrNull(_db.userSettings),
    );
  }

  Future<String?> _activeUserId() async {
    final row = await (_db.select(_db.appPreferences)
          ..where((t) => t.id.equals(_preferencesId)))
        .getSingleOrNull();
    final userId = row?.activeUserId;
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  Future<void> _writeDevice(AppPreferencesCompanion changes) async {
    await _ensureDeviceRow();
    await (_db.update(_db.appPreferences)
          ..where((t) => t.id.equals(_preferencesId)))
        .write(changes);
  }

  Future<void> _ensureDeviceRow() async {
    await _db.into(_db.appPreferences).insert(
          AppPreferencesCompanion.insert(
            id: const Value(_preferencesId),
            themeMode: UserPreferences.defaults().themeMode.name,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _writeSettings(
    String userId,
    UserSettingsCompanion changes,
  ) async {
    await seedSettingsForUser(_db, userId);
    await (_db.update(_db.userSettings)
          ..where((t) => t.userId.equals(userId)))
        .write(changes);
  }

  static Value<bool> _value(bool? value) {
    return value == null ? const Value.absent() : Value(value);
  }
}

import 'package:flutter/material.dart';
import 'package:spendwise/data/mappers/preferences_mapper.dart';
import 'package:spendwise/data/models/app_region.dart';
import 'package:spendwise/data/models/user_preferences.dart';

import '../../core/database/app_database.dart';

class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  Stream<UserPreferences> watchPreferences() {
    return (_db.select(_db.appPreferences)
          ..where((t) => t.id.equals(PreferencesMapper.preferencesId)))
        .watchSingleOrNull()
        .map((row) {
      if (row == null) return UserPreferences.defaults();
      return PreferencesMapper.fromRow(row);
    });
  }

  Future<UserPreferences> getPreferences() async {
    final row = await (_db.select(_db.appPreferences)
          ..where((t) => t.id.equals(PreferencesMapper.preferencesId)))
        .getSingleOrNull();
    return row == null
        ? UserPreferences.defaults()
        : PreferencesMapper.fromRow(row);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = await getPreferences();
    await _upsert(current.copyWith(themeMode: mode));
  }

  Future<void> setRegion(String regionCode) async {
    final current = await getPreferences();
    final region = AppRegion.byCode(regionCode);
    await _upsert(
      current.copyWith(
        regionCode: regionCode,
        currencyCode: region.defaultCurrencyCode,
      ),
    );
  }

  Future<void> setCurrency(String currencyCode) async {
    final current = await getPreferences();
    await _upsert(current.copyWith(currencyCode: currencyCode));
  }

  Future<void> _upsert(UserPreferences preferences) async {
    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          PreferencesMapper.toCompanion(preferences),
        );
  }
}

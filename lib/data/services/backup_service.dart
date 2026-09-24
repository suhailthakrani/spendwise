import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_seed.dart';
import '../../core/utils/password_hasher.dart';
import '../models/backup_snapshot.dart';
import '../models/goal_status.dart';
import '../models/money_log.dart';
import '../models/payment_method.dart';
import '../models/recurring_expense.dart';

class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Builds and restores full-account snapshots. Password hashes never leave
/// the device — Drive backups are JSON of ledger data only.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  Future<BackupSnapshot> createSnapshot({
    required String userId,
    String? driveEmail,
  }) async {
    final profile = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
    if (profile == null) {
      throw BackupException('No account to back up');
    }

    final categories = await (_db.select(_db.categories)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final expenses = await (_db.select(_db.expenses)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final budgets = await (_db.select(_db.budgets)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final recurring = await (_db.select(_db.recurringExpenses)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final goals = await (_db.select(_db.savingGoals)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final contributions = await (_db.select(_db.savingContributions)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final templates = await (_db.select(_db.transactionTemplates)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final envelopes = await (_db.select(_db.envelopes)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final moneyLogs = await (_db.select(_db.moneyLogs)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final settings = await (_db.select(_db.userSettings)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    return BackupSnapshot(
      formatVersion: BackupSnapshot.currentFormatVersion,
      exportedAt: DateTime.now(),
      driveEmail: driveEmail,
      profile: {
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'regionCode': profile.regionCode,
        'currencyCode': profile.currencyCode,
        'googleId': profile.googleId,
        'memberSince': profile.memberSince?.toIso8601String(),
      },
      // Drive linkage is intentionally excluded: it belongs to the device that
      // authorised it, not to the account data being restored.
      settings: settings == null
          ? const {}
          : {
              'themeMode': settings.themeMode,
              'notificationsEnabled': settings.notificationsEnabled,
              'billRemindersEnabled': settings.billRemindersEnabled,
              'budgetAlertsEnabled': settings.budgetAlertsEnabled,
              'goalRemindersEnabled': settings.goalRemindersEnabled,
              'productUpdatesEnabled': settings.productUpdatesEnabled,
              'defaultCategoryId': settings.defaultCategoryId,
              'lastUsedCategoryId': settings.lastUsedCategoryId,
              'dashboardLayoutJson': settings.dashboardLayoutJson,
              'analyticsPeriod': settings.analyticsPeriod,
              'quickActionsJson': settings.quickActionsJson,
            },
      categories: [
        for (final row in categories)
          {
            'id': row.id,
            'name': row.name,
            'iconName': row.iconName,
            'colorValue': row.colorValue,
            'isCustom': row.isCustom,
            'budgetLimit': row.budgetLimit,
          },
      ],
      expenses: [
        for (final row in expenses)
          {
            'id': row.id,
            'amount': row.amount,
            'categoryId': row.categoryId,
            'note': row.note,
            'date': row.date.toIso8601String(),
            'paymentMethod': row.paymentMethod,
            'isRecurring': row.isRecurring,
            'type': row.type,
            'tags': row.tags,
            'attachmentPath': row.attachmentPath,
          },
      ],
      budgets: [
        for (final row in budgets)
          {
            'id': row.id,
            'name': row.name,
            'limitAmount': row.limitAmount,
            'categoryId': row.categoryId,
            'isMonthly': row.isMonthly,
            'year': row.year,
            'month': row.month,
            'periodType': row.periodType,
            'startDate': row.startDate?.toIso8601String(),
            'endDate': row.endDate?.toIso8601String(),
            'rolloverEnabled': row.rolloverEnabled,
            'rolloverAmount': row.rolloverAmount,
            'isSpendingLimit': row.isSpendingLimit,
          },
      ],
      recurringExpenses: [
        for (final row in recurring)
          {
            'id': row.id,
            'title': row.title,
            'amount': row.amount,
            'categoryId': row.categoryId,
            'frequency': row.frequency,
            'nextDueDate': row.nextDueDate.toIso8601String(),
            'paymentMethod': row.paymentMethod,
            'entryType': row.entryType,
            'autoPost': row.autoPost,
          },
      ],
      savingGoals: [
        for (final row in goals)
          {
            'id': row.id,
            'name': row.name,
            'targetAmount': row.targetAmount,
            'deadline': row.deadline?.toIso8601String(),
            'monthlyTarget': row.monthlyTarget,
            'wishlistTitle': row.wishlistTitle,
            'wishlistNote': row.wishlistNote,
            'priority': row.priority,
            'status': row.status,
            'createdAt': row.createdAt.toIso8601String(),
            'updatedAt': row.updatedAt.toIso8601String(),
          },
      ],
      savingContributions: [
        for (final row in contributions)
          {
            'id': row.id,
            'goalId': row.goalId,
            'amount': row.amount,
            'note': row.note,
            'date': row.date.toIso8601String(),
            'createdAt': row.createdAt.toIso8601String(),
          },
      ],
      templates: [
        for (final row in templates)
          {
            'id': row.id,
            'name': row.name,
            'amount': row.amount,
            'categoryId': row.categoryId,
            'type': row.type,
            'note': row.note,
            'paymentMethod': row.paymentMethod,
            'isFavourite': row.isFavourite,
            'useCount': row.useCount,
            'lastUsedAt': row.lastUsedAt?.toIso8601String(),
          },
      ],
      envelopes: [
        for (final row in envelopes)
          {
            'id': row.id,
            'name': row.name,
            'allocated': row.allocated,
            'spent': row.spent,
            'categoryId': row.categoryId,
            'year': row.year,
            'month': row.month,
          },
      ],
      moneyLogs: [
        for (final row in moneyLogs)
          {
            'id': row.id,
            'amount': row.amount,
            'message': row.message,
            'date': row.date.toIso8601String(),
            'direction': row.direction,
          },
      ],
    );
  }

  /// Replaces ledger data for [targetUserId]. Keeps the local password.
  Future<void> restoreIntoUser({
    required BackupSnapshot snapshot,
    required String targetUserId,
  }) async {
    await _db.transaction(() async {
      await _deleteUserLedger(targetUserId);
      final safe = await _withoutIdCollisions(snapshot);
      await _insertLedger(safe, targetUserId);
      await _restoreSettings(snapshot, targetUserId);

      final existing = await (_db.select(_db.userProfiles)
            ..where((t) => t.id.equals(targetUserId)))
          .getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.userProfiles)
              ..where((t) => t.id.equals(targetUserId)))
            .write(
          UserProfilesCompanion(
            name: Value(snapshot.profileName),
            regionCode: Value(
              snapshot.profile['regionCode'] as String? ?? existing.regionCode,
            ),
            currencyCode: Value(
              snapshot.profile['currencyCode'] as String? ??
                  existing.currencyCode,
            ),
          ),
        );
      }
    });
  }

  /// Creates or reuses a local profile, then imports the snapshot.
  /// Returns the local user id. [password] is required when the profile is new.
  Future<String> restoreAsAccount({
    required BackupSnapshot snapshot,
    required String password,
  }) async {
    if (password.length < 6) {
      throw BackupException('Password must be at least 6 characters');
    }

    final email = snapshot.profileEmail;
    if (email.isEmpty || !email.contains('@')) {
      throw BackupException('Backup is missing an account email');
    }

    final existing = await (_db.select(_db.userProfiles)
          ..where((t) => t.email.equals(email)))
        .getSingleOrNull();

    if (existing != null) {
      await restoreIntoUser(snapshot: snapshot, targetUserId: existing.id);
      return existing.id;
    }

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    var userId = snapshot.profileId;
    if (userId.isEmpty) {
      userId = const Uuid().v4();
    } else {
      final idTaken = await (_db.select(_db.userProfiles)
            ..where((t) => t.id.equals(userId)))
          .getSingleOrNull();
      if (idTaken != null) {
        userId = const Uuid().v4();
      }
    }
    final memberSince = DateTime.tryParse(
          '${snapshot.profile['memberSince']}',
        ) ??
        DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.userProfiles).insert(
            UserProfilesCompanion.insert(
              id: userId,
              name: snapshot.profileName,
              email: email,
              passwordHash: Value(hash),
              passwordSalt: Value(salt),
              regionCode: Value(
                snapshot.profile['regionCode'] as String? ?? 'US',
              ),
              currencyCode: Value(
                snapshot.profile['currencyCode'] as String? ?? 'USD',
              ),
              googleId: Value(snapshot.profile['googleId'] as String?),
              memberSince: Value(memberSince),
            ),
          );
      final safe = await _withoutIdCollisions(snapshot);
      await _insertLedger(safe, userId);
      await _restoreSettings(snapshot, userId);
    });

    return userId;
  }

  /// Restores the account's own settings. Drive linkage and the biometric
  /// binding belong to the device that authorised them, so they are not
  /// carried across from a backup.
  Future<void> _restoreSettings(BackupSnapshot snapshot, String userId) async {
    await seedSettingsForUser(_db, userId);
    if (snapshot.settings.isEmpty) return;

    final settings = snapshot.settings;
    await (_db.update(_db.userSettings)..where((t) => t.userId.equals(userId)))
        .write(
      UserSettingsCompanion(
        themeMode: _themeMode(settings['themeMode']),
        notificationsEnabled: _asBool(settings['notificationsEnabled']),
        billRemindersEnabled: _asBool(settings['billRemindersEnabled']),
        budgetAlertsEnabled: _asBool(settings['budgetAlertsEnabled']),
        goalRemindersEnabled: _asBool(settings['goalRemindersEnabled']),
        productUpdatesEnabled: _asBool(settings['productUpdatesEnabled']),
        defaultCategoryId: _asOptionalString(settings['defaultCategoryId']),
        lastUsedCategoryId: _asOptionalString(settings['lastUsedCategoryId']),
        dashboardLayoutJson: _asStringValue(
          settings['dashboardLayoutJson'],
          defaultValue: '',
        ),
        analyticsPeriod: _asStringValue(
          settings['analyticsPeriod'],
          defaultValue: 'oneYear',
        ),
        quickActionsJson: _asStringValue(
          settings['quickActionsJson'],
          defaultValue: '',
        ),
      ),
    );
  }

  Future<void> _deleteUserLedger(String userId) async {
    await (_db.delete(_db.savingContributions)
          ..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.savingGoals)..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.expenses)..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.budgets)..where((t) => t.userId.equals(userId))).go();
    await (_db.delete(_db.recurringExpenses)
          ..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.transactionTemplates)
          ..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.envelopes)..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.moneyLogs)..where((t) => t.userId.equals(userId)))
        .go();
    await (_db.delete(_db.categories)..where((t) => t.userId.equals(userId)))
        .go();
  }

  Future<BackupSnapshot> _withoutIdCollisions(BackupSnapshot snapshot) async {
    final occupied = await _occupiedIds();
    String take(String id) {
      if (!occupied.contains(id)) {
        occupied.add(id);
        return id;
      }
      final next = const Uuid().v4();
      occupied.add(next);
      return next;
    }

    final categoryIds = <String, String>{
      for (final row in snapshot.categories)
        row['id'] as String: take(row['id'] as String),
    };
    final goalIds = <String, String>{
      for (final row in snapshot.savingGoals)
        row['id'] as String: take(row['id'] as String),
    };

    Map<String, Object?> remapRow(
      Map<String, Object?> row, {
      Map<String, String>? extra,
    }) {
      final next = Map<String, Object?>.from(row);
      final id = next['id'] as String?;
      if (id != null) {
        next['id'] = extra?[id] ?? take(id);
      }
      return next;
    }

    String? remapCategory(Object? id) {
      if (id == null) return null;
      final key = id as String;
      return categoryIds[key] ?? key;
    }

    String normalizeType(Object? value) {
      final name = '$value';
      if (name == 'income') return 'income';
      return 'expense';
    }

    return BackupSnapshot(
      formatVersion: snapshot.formatVersion,
      exportedAt: snapshot.exportedAt,
      driveEmail: snapshot.driveEmail,
      profile: snapshot.profile,
      settings: snapshot.settings,
      categories: [
        for (final row in snapshot.categories)
          remapRow(row, extra: categoryIds),
      ],
      expenses: [
        for (final row in snapshot.expenses)
          {
            ...remapRow(row),
            'categoryId':
                categoryIds[row['categoryId'] as String] ?? row['categoryId'],
            'type': normalizeType(row['type']),
          },
      ],
      budgets: [
        for (final row in snapshot.budgets)
          {
            ...remapRow(row),
            'categoryId': remapCategory(row['categoryId']),
          },
      ],
      recurringExpenses: [
        for (final row in snapshot.recurringExpenses)
          {
            ...remapRow(row),
            'categoryId':
                categoryIds[row['categoryId'] as String] ?? row['categoryId'],
            'entryType': normalizeType(row['entryType']),
          },
      ],
      savingGoals: [
        for (final row in snapshot.savingGoals) remapRow(row, extra: goalIds),
      ],
      savingContributions: [
        for (final row in snapshot.savingContributions)
          {
            ...remapRow(row),
            'goalId': goalIds[row['goalId'] as String] ?? row['goalId'],
          },
      ],
      templates: [
        for (final row in snapshot.templates)
          {
            ...remapRow(row),
            'categoryId':
                categoryIds[row['categoryId'] as String] ?? row['categoryId'],
            'type': normalizeType(row['type']),
          },
      ],
      envelopes: [
        for (final row in snapshot.envelopes)
          {
            ...remapRow(row),
            'categoryId': remapCategory(row['categoryId']),
          },
      ],
      moneyLogs: [
        for (final row in snapshot.moneyLogs) remapRow(row),
      ],
    );
  }

  Future<Set<String>> _occupiedIds() async {
    final ids = <String>{};
    ids.addAll((await _db.select(_db.categories).get()).map((r) => r.id));
    ids.addAll((await _db.select(_db.expenses).get()).map((r) => r.id));
    ids.addAll((await _db.select(_db.budgets).get()).map((r) => r.id));
    ids.addAll(
      (await _db.select(_db.recurringExpenses).get()).map((r) => r.id),
    );
    ids.addAll((await _db.select(_db.savingGoals).get()).map((r) => r.id));
    ids.addAll(
      (await _db.select(_db.savingContributions).get()).map((r) => r.id),
    );
    ids.addAll(
      (await _db.select(_db.transactionTemplates).get()).map((r) => r.id),
    );
    ids.addAll((await _db.select(_db.envelopes).get()).map((r) => r.id));
    ids.addAll((await _db.select(_db.moneyLogs).get()).map((r) => r.id));
    return ids;
  }

  Future<void> _insertLedger(BackupSnapshot snapshot, String userId) async {
    if (snapshot.categories.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.categories,
          [
            for (final row in snapshot.categories)
              CategoriesCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                name: row['name'] as String? ?? 'Category',
                iconName: row['iconName'] as String? ?? 'category',
                colorValue: _asInt(row['colorValue']) ??
                    const Color(0xFF0D9488).toARGB32(),
                isCustom: Value(row['isCustom'] as bool? ?? false),
                budgetLimit: Value(_asDouble(row['budgetLimit'])),
              ),
          ],
        );
      });
    }

    await seedIncomeCategoryForUser(_db, userId);

    if (snapshot.expenses.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.expenses,
          [
            for (final row in snapshot.expenses)
              ExpensesCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                amount: _asDouble(row['amount']) ?? 0,
                categoryId: row['categoryId'] as String,
                note: Value(row['note'] as String? ?? ''),
                date: _asDate(row['date']) ?? DateTime.now(),
                paymentMethod: _payment(row['paymentMethod']),
                isRecurring: Value(row['isRecurring'] as bool? ?? false),
                type: Value(_ledgerType(row['type'])),
                tags: Value(row['tags'] as String? ?? ''),
                attachmentPath: Value(row['attachmentPath'] as String?),
              ),
          ],
        );
      });
    }

    if (snapshot.budgets.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.budgets,
          [
            for (final row in snapshot.budgets)
              BudgetsCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                name: row['name'] as String? ?? 'Budget',
                limitAmount: _asDouble(row['limitAmount']) ?? 0,
                categoryId: Value(row['categoryId'] as String?),
                isMonthly: Value(row['isMonthly'] as bool? ?? true),
                year: row['year'] as int? ?? DateTime.now().year,
                month: row['month'] as int? ?? DateTime.now().month,
                periodType: Value(row['periodType'] as String? ?? 'monthly'),
                startDate: Value(_asDate(row['startDate'])),
                endDate: Value(_asDate(row['endDate'])),
                rolloverEnabled: Value(row['rolloverEnabled'] as bool? ?? false),
                rolloverAmount: Value(_asDouble(row['rolloverAmount']) ?? 0),
                isSpendingLimit:
                    Value(row['isSpendingLimit'] as bool? ?? false),
              ),
          ],
        );
      });
    }

    if (snapshot.recurringExpenses.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.recurringExpenses,
          [
            for (final row in snapshot.recurringExpenses)
              RecurringExpensesCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                title: row['title'] as String? ?? 'Recurring',
                amount: _asDouble(row['amount']) ?? 0,
                categoryId: row['categoryId'] as String,
                frequency: _frequency(row['frequency']),
                nextDueDate: _asDate(row['nextDueDate']) ?? DateTime.now(),
                paymentMethod: _payment(row['paymentMethod']),
                entryType: Value(_ledgerType(row['entryType'])),
                autoPost: Value(row['autoPost'] as bool? ?? false),
              ),
          ],
        );
      });
    }

    if (snapshot.savingGoals.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.savingGoals,
          [
            for (final row in snapshot.savingGoals)
              SavingGoalsCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                name: row['name'] as String? ?? 'Goal',
                targetAmount: _asDouble(row['targetAmount']) ?? 0,
                deadline: Value(_asDate(row['deadline'])),
                monthlyTarget: Value(_asDouble(row['monthlyTarget'])),
                wishlistTitle: Value(row['wishlistTitle'] as String?),
                wishlistNote: Value(row['wishlistNote'] as String?),
                priority: Value(_asInt(row['priority']) ?? 0),
                status: Value(
                  GoalStatus.fromDb(row['status'] as String? ?? 'active').name,
                ),
                createdAt: _asDate(row['createdAt']) ?? DateTime.now(),
                updatedAt: _asDate(row['updatedAt']) ?? DateTime.now(),
              ),
          ],
        );
      });
    }

    if (snapshot.savingContributions.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.savingContributions,
          [
            for (final row in snapshot.savingContributions)
              SavingContributionsCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                goalId: row['goalId'] as String,
                amount: _asDouble(row['amount']) ?? 0,
                note: Value(row['note'] as String? ?? ''),
                date: _asDate(row['date']) ?? DateTime.now(),
                createdAt: _asDate(row['createdAt']) ?? DateTime.now(),
              ),
          ],
        );
      });
    }

    if (snapshot.templates.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.transactionTemplates,
          [
            for (final row in snapshot.templates)
              TransactionTemplatesCompanion.insert(
                id: row['id'] as String,
                userId: userId,
                name: row['name'] as String? ?? 'Template',
                amount: _asDouble(row['amount']) ?? 0,
                categoryId: row['categoryId'] as String,
                type: Value(_ledgerType(row['type'])),
                note: Value(row['note'] as String? ?? ''),
                paymentMethod: _payment(row['paymentMethod']),
                isFavourite: Value(row['isFavourite'] as bool? ?? false),
                useCount: Value(_asInt(row['useCount']) ?? 0),
                lastUsedAt: Value(_asDate(row['lastUsedAt'])),
              ),
          ],
        );
      });
    }

    if (snapshot.envelopes.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.envelopes,
          [
            for (final row in snapshot.envelopes)
              EnvelopesCompanion.insert(
                id: row['id'] as String,
                userId: userId,
                name: row['name'] as String? ?? 'Envelope',
                allocated: Value(_asDouble(row['allocated']) ?? 0),
                spent: Value(_asDouble(row['spent']) ?? 0),
                categoryId: Value(row['categoryId'] as String?),
                year: row['year'] as int? ?? DateTime.now().year,
                month: row['month'] as int? ?? DateTime.now().month,
              ),
          ],
        );
      });
    }

    if (snapshot.moneyLogs.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.moneyLogs,
          [
            for (final row in snapshot.moneyLogs)
              MoneyLogsCompanion.insert(
                id: row['id'] as String,
                userId: userId,
                amount: _asDouble(row['amount']) ?? 0,
                message: row['message'] as String? ?? '',
                date: _asDate(row['date']) ?? DateTime.now(),
                direction: Value(
                  MoneyLogDirection.fromStorage(row['direction'] as String?)
                      .storageValue,
                ),
              ),
          ],
        );
      });
    }
  }

  /// Legacy backups may still say `transfer`; treat those as expenses.
  static String _ledgerType(Object? value) {
    final name = '$value';
    if (name == 'income') return 'income';
    return 'expense';
  }

  static Value<bool> _asBool(Object? value) {

    if (value is bool) return Value(value);
    if (value is num) return Value(value != 0);
    return const Value.absent();
  }

  static Value<String?> _asOptionalString(Object? value) {
    if (value == null) return const Value.absent();
    final text = '$value';
    if (text.isEmpty || text == 'null') return const Value(null);
    return Value(text);
  }

  static Value<String> _asStringValue(
    Object? value, {
    required String defaultValue,
  }) {
    if (value == null) return Value(defaultValue);
    final text = '$value';
    if (text == 'null') return Value(defaultValue);
    return Value(text);
  }

  static Value<String> _themeMode(Object? value) {
    for (final mode in ThemeMode.values) {
      if (mode.name == value) return Value(mode.name);
    }
    return const Value.absent();
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static DateTime? _asDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse('$value');
  }

  static String _payment(Object? value) {
    final name = '$value';
    for (final method in PaymentMethod.values) {
      if (method.name == name) return method.name;
    }
    return PaymentMethod.other.name;
  }

  static String _frequency(Object? value) {
    final name = '$value';
    for (final frequency in RecurrenceFrequency.values) {
      if (frequency.name == name) return frequency.name;
    }
    return RecurrenceFrequency.monthly.name;
  }
}

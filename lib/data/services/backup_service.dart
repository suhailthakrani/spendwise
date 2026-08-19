import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/password_hasher.dart';
import '../models/backup_snapshot.dart';
import '../models/goal_status.dart';
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
        'memberSince': profile.memberSince?.toIso8601String(),
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
              memberSince: Value(memberSince),
            ),
          );
      final safe = await _withoutIdCollisions(snapshot);
      await _insertLedger(safe, userId);
    });

    return userId;
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

    return BackupSnapshot(
      formatVersion: snapshot.formatVersion,
      exportedAt: snapshot.exportedAt,
      driveEmail: snapshot.driveEmail,
      profile: snapshot.profile,
      categories: [
        for (final row in snapshot.categories) remapRow(row, extra: categoryIds),
      ],
      expenses: [
        for (final row in snapshot.expenses)
          {
            ...remapRow(row),
            'categoryId': categoryIds[row['categoryId'] as String] ??
                row['categoryId'],
          },
      ],
      budgets: [
        for (final row in snapshot.budgets)
          {
            ...remapRow(row),
            'categoryId': row['categoryId'] == null
                ? null
                : (categoryIds[row['categoryId'] as String] ??
                    row['categoryId']),
          },
      ],
      recurringExpenses: [
        for (final row in snapshot.recurringExpenses)
          {
            ...remapRow(row),
            'categoryId': categoryIds[row['categoryId'] as String] ??
                row['categoryId'],
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

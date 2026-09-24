import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/data/models/money_log.dart';
import 'package:spendwise/data/repositories/money_log_repository.dart';
import 'package:spendwise/data/services/backup_service.dart';

void main() {
  test('logs stay out of expenses and round-trip through backup', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: 'user_a',
            name: 'Ada',
            email: 'ada@example.com',
          ),
        );

    final repo = MoneyLogRepository(db, 'user_a');
    final now = DateTime(2026, 9, 24, 10);
    await repo.create(
      MoneyLog(
        id: 'log_1',
        amount: 40,
        message: 'Family medical',
        date: now,
      ),
    );
    await repo.create(
      MoneyLog(
        id: 'log_old',
        amount: 10,
        message: 'Last month',
        date: DateTime(2026, 8, 2),
      ),
    );

    final logs = await repo.watchAll().first;
    final month = MoneyLog.inMonth(logs, now);
    expect(month, hasLength(1));
    expect(month.single.message, 'Family medical');
    expect(MoneyLog.total(month), 40);
    expect(await db.select(db.expenses).get(), isEmpty);

    final snapshot = await BackupService(db).createSnapshot(userId: 'user_a');
    expect(snapshot.moneyLogs, hasLength(2));

    await repo.delete('log_1');
    expect(await repo.watchAll().first, hasLength(1));

    await BackupService(db).restoreIntoUser(
      snapshot: snapshot,
      targetUserId: 'user_a',
    );
    final restored = await repo.watchAll().first;
    expect(restored.map((l) => l.message), contains('Family medical'));
  });
}

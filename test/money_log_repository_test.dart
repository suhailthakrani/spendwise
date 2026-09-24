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
        id: 'log_in',
        amount: 25,
        message: 'Refund',
        date: now,
        direction: MoneyLogDirection.incoming,
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
    expect(month, hasLength(2));
    expect(month.map((l) => l.message), contains('Family medical'));
    expect(MoneyLog.totalOut(month), 40);
    expect(MoneyLog.totalIn(month), 25);
    expect(
      month.singleWhere((l) => l.id == 'log_in').direction,
      MoneyLogDirection.incoming,
    );
    expect(await db.select(db.expenses).get(), isEmpty);

    final snapshot = await BackupService(db).createSnapshot(userId: 'user_a');
    expect(snapshot.moneyLogs, hasLength(3));
    expect(
      snapshot.moneyLogs.singleWhere((row) => row['id'] == 'log_in')['direction'],
      'in',
    );

    await repo.delete('log_1');
    expect(await repo.watchAll().first, hasLength(2));

    await BackupService(db).restoreIntoUser(
      snapshot: snapshot,
      targetUserId: 'user_a',
    );
    final restored = await repo.watchAll().first;
    expect(restored.map((l) => l.message), contains('Family medical'));
    expect(
      restored.singleWhere((l) => l.id == 'log_in').direction,
      MoneyLogDirection.incoming,
    );
  });
}

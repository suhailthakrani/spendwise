import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:spendwise/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('spendwise_v10');
    dbPath = p.join(tempDir.path, 'spendwise.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('v9 upgrade creates money_logs', () async {
    final raw = sqlite3.open(dbPath);
    raw.execute('PRAGMA user_version = 9');
    raw.dispose();

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], 11);

    final cols = await db.customSelect('PRAGMA table_info(money_logs)').get();
    final names = cols.map((r) => r.data['name']).toSet();
    expect(
      names,
      containsAll(['id', 'user_id', 'amount', 'message', 'date', 'direction']),
    );
  });

  test('v10 upgrade defaults existing logs to out', () async {
    final raw = sqlite3.open(dbPath);
    raw.execute('PRAGMA user_version = 10');
    raw.execute('''
      CREATE TABLE money_logs (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        message TEXT NOT NULL,
        date INTEGER NOT NULL
      )
    ''');
    raw.execute('''
      INSERT INTO money_logs (id, user_id, amount, message, date)
      VALUES ('log_1', 'user_a', 12, 'Taxi', 0)
    ''');
    raw.dispose();

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], 11);

    final row = await db.select(db.moneyLogs).getSingle();
    expect(row.direction, 'out');
  });
}

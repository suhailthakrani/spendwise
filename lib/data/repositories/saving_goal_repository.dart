import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/saving_contribution_mapper.dart';
import '../mappers/saving_goal_mapper.dart';
import '../models/goal_status.dart';
import '../models/saving_contribution.dart';
import '../models/saving_goal.dart';

class SavingGoalRepository {
  SavingGoalRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;
  static const _uuid = Uuid();

  Stream<List<SavingGoal>> watchAll() {
    return (_db.select(_db.savingGoals)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .asyncMap((rows) async {
      final goals = <SavingGoal>[];
      for (final row in rows) {
        final saved = await _sumContributions(row.id);
        goals.add(SavingGoalMapper.fromRow(row, savedAmount: saved));
      }
      return goals;
    });
  }

  Stream<List<SavingGoal>> watchActive() {
    return watchAll().map(
      (goals) => goals
          .where((g) => g.status == GoalStatus.active && !g.isAchieved)
          .toList(),
    );
  }

  Stream<SavingGoal?> watchById(String id) {
    return (_db.select(_db.savingGoals)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .watchSingleOrNull()
        .asyncMap((row) async {
      if (row == null) return null;
      final saved = await _sumContributions(row.id);
      return SavingGoalMapper.fromRow(row, savedAmount: saved);
    });
  }

  Future<SavingGoal?> getById(String id) async {
    final row = await (_db.select(_db.savingGoals)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .getSingleOrNull();
    if (row == null) return null;
    final saved = await _sumContributions(row.id);
    return SavingGoalMapper.fromRow(row, savedAmount: saved);
  }

  Stream<List<SavingContribution>> watchContributions(String goalId) {
    return (_db.select(_db.savingContributions)
          ..where(
            (t) => t.goalId.equals(goalId) & t.userId.equals(_userId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map(SavingContributionMapper.fromRow).toList());
  }

  Future<double> savedThisMonth(String goalId, [DateTime? now]) async {
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, n.month, 1);
    final end = DateTime(n.year, n.month + 1, 0, 23, 59, 59);

    final query = _db.selectOnly(_db.savingContributions)
      ..addColumns([_db.savingContributions.amount.sum()])
      ..where(
        _db.savingContributions.userId.equals(_userId) &
            _db.savingContributions.goalId.equals(goalId) &
            _db.savingContributions.date.isBetweenValues(start, end),
      );

    final row = await query.getSingle();
    return row.read(_db.savingContributions.amount.sum()) ?? 0;
  }

  Future<void> create(SavingGoal goal) async {
    await _db.into(_db.savingGoals).insert(
          SavingGoalMapper.toCompanion(goal, userId: _userId),
        );
  }

  Future<void> update(SavingGoal goal) async {
    await (_db.update(_db.savingGoals)
          ..where((t) => t.id.equals(goal.id) & t.userId.equals(_userId)))
        .write(
      SavingGoalsCompanion(
        name: Value(goal.name),
        targetAmount: Value(goal.targetAmount),
        deadline: Value(goal.deadline),
        monthlyTarget: Value(goal.monthlyTarget),
        wishlistTitle: Value(goal.wishlistTitle),
        wishlistNote: Value(goal.wishlistNote),
        priority: Value(goal.priority),
        status: Value(goal.status.name),
        updatedAt: Value(goal.updatedAt),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.savingContributions)
          ..where((t) => t.goalId.equals(id) & t.userId.equals(_userId)))
        .go();
    await (_db.delete(_db.savingGoals)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }

  Future<void> addContribution(SavingContribution contribution) async {
    await _db.transaction(() async {
      await _db.into(_db.savingContributions).insert(
            SavingContributionMapper.toCompanion(
              contribution,
              userId: _userId,
            ),
          );

      final goal = await getById(contribution.goalId);
      if (goal != null && goal.savedAmount >= goal.targetAmount) {
        await (_db.update(_db.savingGoals)
              ..where(
                (t) =>
                    t.id.equals(contribution.goalId) &
                    t.userId.equals(_userId),
              ))
            .write(
          SavingGoalsCompanion(
            status: Value(GoalStatus.achieved.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await (_db.update(_db.savingGoals)
              ..where(
                (t) =>
                    t.id.equals(contribution.goalId) &
                    t.userId.equals(_userId),
              ))
            .write(
          SavingGoalsCompanion(updatedAt: Value(DateTime.now())),
        );
      }
    });
  }

  Future<void> deleteContribution(String id, String goalId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.savingContributions)
            ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
          .go();

      final goal = await getById(goalId);
      if (goal != null &&
          goal.status == GoalStatus.achieved &&
          goal.savedAmount < goal.targetAmount) {
        await (_db.update(_db.savingGoals)
              ..where((t) => t.id.equals(goalId) & t.userId.equals(_userId)))
            .write(
          SavingGoalsCompanion(
            status: Value(GoalStatus.active.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await (_db.update(_db.savingGoals)
              ..where((t) => t.id.equals(goalId) & t.userId.equals(_userId)))
            .write(
          SavingGoalsCompanion(updatedAt: Value(DateTime.now())),
        );
      }
    });
  }

  Future<double> _sumContributions(String goalId) async {
    final query = _db.selectOnly(_db.savingContributions)
      ..addColumns([_db.savingContributions.amount.sum()])
      ..where(
        _db.savingContributions.userId.equals(_userId) &
            _db.savingContributions.goalId.equals(goalId),
      );
    final row = await query.getSingle();
    return row.read(_db.savingContributions.amount.sum()) ?? 0;
  }

  String newId() => _uuid.v4();
}

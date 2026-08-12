import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/goal_status.dart';
import '../models/saving_goal.dart';

abstract final class SavingGoalMapper {
  static SavingGoal fromRow(SavingGoalRow row, {required double savedAmount}) {
    return SavingGoal(
      id: row.id,
      name: row.name,
      targetAmount: row.targetAmount,
      savedAmount: savedAmount,
      deadline: row.deadline,
      monthlyTarget: row.monthlyTarget,
      wishlistTitle: row.wishlistTitle,
      wishlistNote: row.wishlistNote,
      priority: row.priority,
      status: GoalStatus.fromDb(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static SavingGoalsCompanion toCompanion(
    SavingGoal goal, {
    required String userId,
  }) {
    return SavingGoalsCompanion(
      id: Value(goal.id),
      userId: Value(userId),
      name: Value(goal.name),
      targetAmount: Value(goal.targetAmount),
      deadline: Value(goal.deadline),
      monthlyTarget: Value(goal.monthlyTarget),
      wishlistTitle: Value(goal.wishlistTitle),
      wishlistNote: Value(goal.wishlistNote),
      priority: Value(goal.priority),
      status: Value(goal.status.name),
      createdAt: Value(goal.createdAt),
      updatedAt: Value(goal.updatedAt),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/goal_pace_calculator.dart';
import 'package:spendwise/data/models/goal_status.dart';
import 'package:spendwise/data/models/saving_goal.dart';

void main() {
  SavingGoal goal({
    required double target,
    required double saved,
    double? monthlyTarget,
    double savedThisMonth = 0,
  }) {
    final now = DateTime(2026, 9, 16);
    return SavingGoal(
      id: 'g1',
      name: 'Emergency',
      targetAmount: target,
      savedAmount: saved,
      monthlyTarget: monthlyTarget,
      priority: 0,
      status: GoalStatus.active,
      createdAt: now,
      updatedAt: now,
      savedThisMonth: savedThisMonth,
    );
  }

  test('does not nag when this month already meets the frequency', () {
    final item = goal(
      target: 500000,
      saved: 200000,
      monthlyTarget: 120000,
      savedThisMonth: 200000,
    );

    expect(GoalPaceCalculator.requiredThisMonth(item), 120000);
    expect(GoalPaceCalculator.remainingToStayOnPace(item), 0);
  });

  test('asks only for the remaining frequency gap', () {
    final item = goal(
      target: 500000,
      saved: 50000,
      monthlyTarget: 120000,
      savedThisMonth: 40000,
    );

    expect(GoalPaceCalculator.remainingToStayOnPace(item), 80000);
  });
}

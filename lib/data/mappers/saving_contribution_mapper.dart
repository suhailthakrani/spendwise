import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/saving_contribution.dart';

abstract final class SavingContributionMapper {
  static SavingContribution fromRow(SavingContributionRow row) {
    return SavingContribution(
      id: row.id,
      goalId: row.goalId,
      amount: row.amount,
      note: row.note,
      date: row.date,
      createdAt: row.createdAt,
    );
  }

  static SavingContributionsCompanion toCompanion(
    SavingContribution contribution, {
    required String userId,
  }) {
    return SavingContributionsCompanion(
      id: Value(contribution.id),
      userId: Value(userId),
      goalId: Value(contribution.goalId),
      amount: Value(contribution.amount),
      note: Value(contribution.note),
      date: Value(contribution.date),
      createdAt: Value(contribution.createdAt),
    );
  }
}

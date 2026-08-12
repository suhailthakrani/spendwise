import 'goal_status.dart';

class SavingGoal {
  const SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deadline,
    this.monthlyTarget,
    this.wishlistTitle,
    this.wishlistNote,
  });

  final String id;
  final String name;
  /// Target in USD storage currency.
  final double targetAmount;
  /// Sum of contributions in USD storage currency.
  final double savedAmount;
  final DateTime? deadline;
  /// Optional explicit monthly save amount in USD.
  final double? monthlyTarget;
  final String? wishlistTitle;
  final String? wishlistNote;
  final int priority;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get remaining =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isAchieved =>
      status == GoalStatus.achieved || savedAmount >= targetAmount;
  bool get hasWishlist =>
      (wishlistTitle != null && wishlistTitle!.trim().isNotEmpty);

  SavingGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    double? monthlyTarget,
    String? wishlistTitle,
    String? wishlistNote,
    int? priority,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDeadline = false,
    bool clearMonthlyTarget = false,
    bool clearWishlistTitle = false,
    bool clearWishlistNote = false,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      monthlyTarget:
          clearMonthlyTarget ? null : (monthlyTarget ?? this.monthlyTarget),
      wishlistTitle:
          clearWishlistTitle ? null : (wishlistTitle ?? this.wishlistTitle),
      wishlistNote:
          clearWishlistNote ? null : (wishlistNote ?? this.wishlistNote),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum GoalStatus {
  active,
  achieved,
  paused;

  static GoalStatus fromDb(String value) {
    return GoalStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => GoalStatus.active,
    );
  }
}

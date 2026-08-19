class BackupSnapshot {
  const BackupSnapshot({
    required this.formatVersion,
    required this.exportedAt,
    required this.profile,
    required this.categories,
    required this.expenses,
    required this.budgets,
    required this.recurringExpenses,
    required this.savingGoals,
    required this.savingContributions,
    this.driveEmail,
  });

  static const currentFormatVersion = 1;
  static const formatName = 'spendwise-backup';

  final int formatVersion;
  final DateTime exportedAt;
  final String? driveEmail;
  final Map<String, Object?> profile;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> expenses;
  final List<Map<String, Object?>> budgets;
  final List<Map<String, Object?>> recurringExpenses;
  final List<Map<String, Object?>> savingGoals;
  final List<Map<String, Object?>> savingContributions;

  String get profileId => profile['id'] as String? ?? '';
  String get profileEmail =>
      (profile['email'] as String? ?? '').trim().toLowerCase();
  String get profileName => profile['name'] as String? ?? 'SpendWise user';

  Map<String, Object?> toJson() {
    return {
      'format': formatName,
      'formatVersion': formatVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'driveEmail': driveEmail,
      'profile': profile,
      'categories': categories,
      'expenses': expenses,
      'budgets': budgets,
      'recurringExpenses': recurringExpenses,
      'savingGoals': savingGoals,
      'savingContributions': savingContributions,
    };
  }

  factory BackupSnapshot.fromJson(Map<String, Object?> json) {
    final format = json['format'] as String?;
    if (format != null && format != formatName) {
      throw const FormatException('Not a SpendWise backup file');
    }
    final version = json['formatVersion'];
    if (version is! int || version < 1) {
      throw const FormatException('Unsupported backup version');
    }

    Map<String, Object?> objectMap(Object? value) {
      if (value is Map<String, Object?>) return value;
      if (value is Map) {
        return value.map((key, v) => MapEntry(key.toString(), v));
      }
      return {};
    }

    List<Map<String, Object?>> objectList(Object? value) {
      if (value is! List) return [];
      return value.map(objectMap).toList();
    }

    return BackupSnapshot(
      formatVersion: version,
      exportedAt: DateTime.tryParse('${json['exportedAt']}') ?? DateTime.now(),
      driveEmail: json['driveEmail'] as String?,
      profile: objectMap(json['profile']),
      categories: objectList(json['categories']),
      expenses: objectList(json['expenses']),
      budgets: objectList(json['budgets']),
      recurringExpenses: objectList(json['recurringExpenses']),
      savingGoals: objectList(json['savingGoals']),
      savingContributions: objectList(json['savingContributions']),
    );
  }
}

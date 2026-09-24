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
    this.settings = const {},
    this.templates = const [],
    this.envelopes = const [],
    this.moneyLogs = const [],
  });

  static const currentFormatVersion = 6;
  static const formatName = 'spendwise-backup';

  final int formatVersion;
  final DateTime exportedAt;
  final String? driveEmail;
  final Map<String, Object?> profile;

  /// Account settings (theme, notification choices). Empty for version 1 files.
  final Map<String, Object?> settings;

  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> expenses;
  final List<Map<String, Object?>> budgets;
  final List<Map<String, Object?>> recurringExpenses;
  final List<Map<String, Object?>> savingGoals;
  final List<Map<String, Object?>> savingContributions;

  /// Transaction templates. Empty for version ≤3 files.
  final List<Map<String, Object?>> templates;

  /// Envelope allocations. Empty for version ≤3 files.
  final List<Map<String, Object?>> envelopes;

  /// Spending kept out of the budget. Empty for version ≤5 files.
  final List<Map<String, Object?>> moneyLogs;

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
      'settings': settings,
      'categories': categories,
      'expenses': expenses,
      'budgets': budgets,
      'recurringExpenses': recurringExpenses,
      'savingGoals': savingGoals,
      'savingContributions': savingContributions,
      'templates': templates,
      'envelopes': envelopes,
      'moneyLogs': moneyLogs,
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

    // Legacy `accounts` key (format ≤4) is intentionally ignored.
    return BackupSnapshot(
      formatVersion: version,
      exportedAt: DateTime.tryParse('${json['exportedAt']}') ?? DateTime.now(),
      driveEmail: json['driveEmail'] as String?,
      profile: objectMap(json['profile']),
      settings: objectMap(json['settings']),
      categories: objectList(json['categories']),
      expenses: objectList(json['expenses']),
      budgets: objectList(json['budgets']),
      recurringExpenses: objectList(json['recurringExpenses']),
      savingGoals: objectList(json['savingGoals']),
      savingContributions: objectList(json['savingContributions']),
      templates: objectList(json['templates']),
      envelopes: objectList(json['envelopes']),
      moneyLogs: objectList(json['moneyLogs']),
    );
  }
}

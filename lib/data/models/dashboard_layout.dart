import 'dart:convert';

enum DashboardWidgetId {
  balance,
  safeToSpend,
  forecast,
  budgets,
  goals,
  recent,
  calendar,
  charts,
  insights;

  static DashboardWidgetId? tryParse(String id) {
    for (final value in DashboardWidgetId.values) {
      if (value.name == id) return value;
    }
    return null;
  }

  String get label => switch (this) {
        DashboardWidgetId.balance => 'Overview',
        DashboardWidgetId.safeToSpend => 'Safe to spend',
        DashboardWidgetId.forecast => 'Forecast',
        DashboardWidgetId.budgets => 'Budgets',
        DashboardWidgetId.goals => 'Goals',
        DashboardWidgetId.recent => 'Recent',
        DashboardWidgetId.calendar => 'Calendar',
        DashboardWidgetId.charts => 'Charts',
        DashboardWidgetId.insights => 'Insights',
      };
}

class DashboardLayout {
  const DashboardLayout({required this.widgets});

  final List<DashboardWidgetId> widgets;

  static DashboardLayout defaults() {
    // Keep first-run Home calm: status → recent → budget.
    // Advanced widgets stay available via Customize home.
    return const DashboardLayout(
      widgets: [
        DashboardWidgetId.balance,
        DashboardWidgetId.recent,
        DashboardWidgetId.budgets,
      ],
    );
  }

  /// Parses a JSON list of widget id strings. Unknown ids are skipped.
  static DashboardLayout fromJson(String? json) {
    if (json == null || json.trim().isEmpty) return defaults();
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return defaults();
      final widgets = <DashboardWidgetId>[];
      for (final item in decoded) {
        if (item is! String) continue;
        final id = DashboardWidgetId.tryParse(item);
        if (id != null) widgets.add(id);
      }
      if (widgets.isEmpty) return defaults();
      return DashboardLayout(widgets: List.unmodifiable(widgets));
    } catch (_) {
      return defaults();
    }
  }

  String toJson() {
    return jsonEncode(widgets.map((w) => w.name).toList());
  }

  DashboardLayout copyWith({List<DashboardWidgetId>? widgets}) {
    return DashboardLayout(
      widgets: widgets ?? this.widgets,
    );
  }
}

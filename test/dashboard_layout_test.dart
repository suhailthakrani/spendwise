import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/models/dashboard_layout.dart';

void main() {
  test('defaults include core widgets', () {
    final layout = DashboardLayout.defaults();
    expect(layout.widgets, contains(DashboardWidgetId.balance));
    expect(layout.widgets, contains(DashboardWidgetId.safeToSpend));
    expect(layout.widgets, isNotEmpty);
  });

  test('fromJson skips unknown widget ids', () {
    final layout = DashboardLayout.fromJson(
      '["balance","notARealWidget","goals","legacyThing","recent"]',
    );
    expect(layout.widgets, [
      DashboardWidgetId.balance,
      DashboardWidgetId.goals,
      DashboardWidgetId.recent,
    ]);
  });

  test('fromJson falls back to defaults on null, empty, or invalid json', () {
    expect(DashboardLayout.fromJson(null).widgets,
        DashboardLayout.defaults().widgets);
    expect(DashboardLayout.fromJson('').widgets,
        DashboardLayout.defaults().widgets);
    expect(DashboardLayout.fromJson('{bad').widgets,
        DashboardLayout.defaults().widgets);
    expect(DashboardLayout.fromJson('[]').widgets,
        DashboardLayout.defaults().widgets);
    expect(DashboardLayout.fromJson('["unknown"]').widgets,
        DashboardLayout.defaults().widgets);
  });

  test('toJson / fromJson round-trip', () {
    final original = DashboardLayout(
      widgets: const [
        DashboardWidgetId.charts,
        DashboardWidgetId.calendar,
        DashboardWidgetId.insights,
      ],
    );
    final restored = DashboardLayout.fromJson(original.toJson());
    expect(restored.widgets, original.widgets);
  });

  test('tryParse and labels', () {
    expect(DashboardWidgetId.tryParse('forecast'), DashboardWidgetId.forecast);
    expect(DashboardWidgetId.tryParse('accounts'), isNull);
    expect(DashboardWidgetId.tryParse('nope'), isNull);
    expect(DashboardWidgetId.safeToSpend.label, 'Safe to spend');
  });

  test('copyWith replaces widgets', () {
    final layout = DashboardLayout.defaults().copyWith(
      widgets: const [DashboardWidgetId.balance],
    );
    expect(layout.widgets, [DashboardWidgetId.balance]);
  });
}

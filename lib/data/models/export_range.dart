enum ExportRangePreset {
  thisMonth,
  last3Months,
  thisYear,
  allTime,
  custom;

  String get label => switch (this) {
        ExportRangePreset.thisMonth => 'This month',
        ExportRangePreset.last3Months => 'Last 3 months',
        ExportRangePreset.thisYear => 'This year',
        ExportRangePreset.allTime => 'All time',
        ExportRangePreset.custom => 'Custom',
      };
}

class ExportDateRange {
  const ExportDateRange({
    required this.preset,
    this.start,
    this.end,
  });

  final ExportRangePreset preset;
  final DateTime? start;
  final DateTime? end;

  /// Inclusive calendar bounds for querying expenses.
  (DateTime? start, DateTime? end) resolve([DateTime? now]) {
    final n = now ?? DateTime.now();
    switch (preset) {
      case ExportRangePreset.thisMonth:
        return (
          DateTime(n.year, n.month, 1),
          DateTime(n.year, n.month + 1, 0),
        );
      case ExportRangePreset.last3Months:
        final startMonth = DateTime(n.year, n.month - 2, 1);
        return (startMonth, DateTime(n.year, n.month + 1, 0));
      case ExportRangePreset.thisYear:
        return (DateTime(n.year, 1, 1), DateTime(n.year, 12, 31));
      case ExportRangePreset.allTime:
        return (null, null);
      case ExportRangePreset.custom:
        return (start, end);
    }
  }

  String get displayLabel {
    if (preset != ExportRangePreset.custom) return preset.label;
    if (start == null && end == null) return 'Custom';
    final s = start;
    final e = end;
    if (s != null && e != null) {
      return '${_short(s)} – ${_short(e)}';
    }
    if (s != null) return 'From ${_short(s)}';
    return 'Until ${_short(e!)}';
  }

  static String _short(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

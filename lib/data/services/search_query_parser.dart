class ParsedSearchQuery {
  const ParsedSearchQuery({
    required this.text,
    this.minAmount,
    this.maxAmount,
    this.startDate,
    this.endDate,
    this.tags = const [],
  });

  /// Remaining free-text note search after tokens are stripped.
  final String text;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tags;
}

/// Tokenizes a natural-language expense search string.
abstract final class SearchQueryParser {
  static ParsedSearchQuery parse(String raw, {required DateTime now}) {
    var remaining = raw.trim();
    double? minAmount;
    double? maxAmount;
    DateTime? startDate;
    DateTime? endDate;
    final tags = <String>[];

    // #tag tokens
    remaining = remaining.replaceAllMapped(RegExp(r'#(\w+)'), (m) {
      tags.add(m.group(1)!.toLowerCase());
      return ' ';
    });

    // Amount: above / over / > N
    final above = RegExp(
      r'(?:above|over)\s+(\d+(?:\.\d+)?)|(?:>\s*)(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );
    remaining = remaining.replaceAllMapped(above, (m) {
      final v = double.tryParse(m.group(1) ?? m.group(2) ?? '');
      if (v != null) minAmount = v;
      return ' ';
    });

    // Amount: below / under / < N
    final below = RegExp(
      r'(?:below|under)\s+(\d+(?:\.\d+)?)|(?:<\s*)(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );
    remaining = remaining.replaceAllMapped(below, (m) {
      final v = double.tryParse(m.group(1) ?? m.group(2) ?? '');
      if (v != null) maxAmount = v;
      return ' ';
    });

    // Relative date ranges (order: longer phrases first)
    final lastNMonths = RegExp(
      r'last\s+(\d+)\s+months?',
      caseSensitive: false,
    );
    remaining = remaining.replaceAllMapped(lastNMonths, (m) {
      final n = int.tryParse(m.group(1) ?? '') ?? 1;
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final startMonth = DateTime(now.year, now.month - (n - 1), 1);
      startDate = startMonth;
      endDate = end;
      return ' ';
    });

    if (RegExp(r'\blast\s+month\b', caseSensitive: false).hasMatch(remaining)) {
      remaining = remaining.replaceAll(
        RegExp(r'\blast\s+month\b', caseSensitive: false),
        ' ',
      );
      final prev = DateTime(now.year, now.month - 1, 1);
      startDate = prev;
      endDate = DateTime(prev.year, prev.month + 1, 0, 23, 59, 59);
    }

    if (RegExp(r'\bthis\s+month\b', caseSensitive: false).hasMatch(remaining)) {
      remaining = remaining.replaceAll(
        RegExp(r'\bthis\s+month\b', caseSensitive: false),
        ' ',
      );
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    if (RegExp(r'\bthis\s+week\b', caseSensitive: false).hasMatch(remaining)) {
      remaining = remaining.replaceAll(
        RegExp(r'\bthis\s+week\b', caseSensitive: false),
        ' ',
      );
      final weekday = now.weekday; // Mon=1
      startDate = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: weekday - 1));
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    final text = remaining.replaceAll(RegExp(r'\s+'), ' ').trim();
    return ParsedSearchQuery(
      text: text,
      minAmount: minAmount,
      maxAmount: maxAmount,
      startDate: startDate,
      endDate: endDate,
      tags: List.unmodifiable(tags),
    );
  }
}

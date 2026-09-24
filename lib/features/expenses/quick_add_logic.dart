/// Pure helpers for the quick-add numeric keypad (no Flutter dependency).
abstract final class QuickAddLogic {
  /// Applies a keypad key (`0`-`9`, `.`, or `backspace`) to [current].
  static String applyKey(
    String current,
    String key, {
    int decimalDigits = 2,
  }) {
    if (key == 'backspace') {
      if (current.isEmpty) return '';
      return current.substring(0, current.length - 1);
    }

    if (key == '.') {
      if (decimalDigits <= 0) return current;
      if (current.contains('.')) return current;
      return current.isEmpty ? '0.' : '$current.';
    }

    if (key.length != 1 || key.compareTo('0') < 0 || key.compareTo('9') > 0) {
      return current;
    }

    if (current == '0') return key;

    final dot = current.indexOf('.');
    if (dot >= 0) {
      final decimals = current.length - dot - 1;
      if (decimals >= decimalDigits) return current;
    }

    return '$current$key';
  }

  /// Resolves the category to preselect for quick-add.
  static String? resolveCategoryId({
    required List<String> rankedCategoryIds,
    String? lastUsedCategoryId,
    String? defaultCategoryId,
  }) {
    if (rankedCategoryIds.isEmpty) return null;
    if (lastUsedCategoryId != null &&
        rankedCategoryIds.contains(lastUsedCategoryId)) {
      return lastUsedCategoryId;
    }
    if (defaultCategoryId != null &&
        rankedCategoryIds.contains(defaultCategoryId)) {
      return defaultCategoryId;
    }
    return rankedCategoryIds.first;
  }
}

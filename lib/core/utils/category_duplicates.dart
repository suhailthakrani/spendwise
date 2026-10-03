import '../../data/models/category.dart';
import '../database/database_seed.dart';

/// A leftover pair that auto-dedupe did not merge (fuzzy / nested names).
class CategoryDuplicatePair {
  const CategoryDuplicatePair({
    required this.left,
    required this.right,
  });

  final ExpenseCategory left;
  final ExpenseCategory right;

  /// Stable key for dismiss storage.
  String get dismissKey {
    final ids = [left.id, right.id]..sort();
    return ids.join('|');
  }

  /// Prefer merging custom → built-in when possible.
  ExpenseCategory get suggestedFrom =>
      left.isCustom && !right.isCustom
          ? left
          : right.isCustom && !left.isCustom
              ? right
              : left;

  ExpenseCategory get suggestedInto =>
      suggestedFrom.id == left.id ? right : left;
}

/// Finds likely leftover duplicates. Exact alias matches are ignored (auto-dedupe
/// should already have cleaned those).
List<CategoryDuplicatePair> findLikelyDuplicatePairs(
  List<ExpenseCategory> categories,
) {
  if (categories.length < 2) return const [];

  final pairs = <CategoryDuplicatePair>[];
  for (var i = 0; i < categories.length; i++) {
    for (var j = i + 1; j < categories.length; j++) {
      final a = categories[i];
      final b = categories[j];
      // Same canonical key should already be merged; skip if somehow equal.
      if (categoryMatchKey(a.name) == categoryMatchKey(b.name)) {
        pairs.add(CategoryDuplicatePair(left: a, right: b));
        continue;
      }
      if (_looksSimilar(a.name, b.name)) {
        pairs.add(CategoryDuplicatePair(left: a, right: b));
      }
    }
  }

  // Prefer pairs that involve a custom category (user leftovers).
  pairs.sort((x, y) {
    final xCustom = (x.left.isCustom ? 1 : 0) + (x.right.isCustom ? 1 : 0);
    final yCustom = (y.left.isCustom ? 1 : 0) + (y.right.isCustom ? 1 : 0);
    return yCustom.compareTo(xCustom);
  });
  return pairs;
}

bool _looksSimilar(String a, String b) {
  final na = _normalize(a);
  final nb = _normalize(b);
  if (na.isEmpty || nb.isEmpty || na == nb) return na == nb && na.isNotEmpty;

  final shorter = na.length <= nb.length ? na : nb;
  final longer = na.length <= nb.length ? nb : na;

  // Nested labels: "Gym" inside "Gym fees"
  if (shorter.length >= 3 &&
      (longer.startsWith('$shorter ') ||
          longer.endsWith(' $shorter') ||
          longer.contains(' $shorter '))) {
    return true;
  }

  // Close typos / plurals the alias map missed.
  if (shorter.length >= 4 && _levenshtein(na, nb) <= 2) return true;

  return false;
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('&', ' and ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = [
        prev[j] + 1,
        curr[j - 1] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    for (var j = 0; j <= b.length; j++) {
      prev[j] = curr[j];
    }
  }
  return prev[b.length];
}

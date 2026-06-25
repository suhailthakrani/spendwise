import '../../data/models/category.dart';

ExpenseCategory? categoryById(
  List<ExpenseCategory> categories,
  String id,
) {
  for (final category in categories) {
    if (category.id == id) return category;
  }
  return null;
}

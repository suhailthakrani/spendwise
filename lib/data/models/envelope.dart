class Envelope {
  const Envelope({
    required this.id,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.year,
    required this.month,
    this.categoryId,
  });

  final String id;
  final String name;
  /// Stored in the app's base currency (USD).
  final double allocated;
  final double spent;
  final String? categoryId;
  final int year;
  final int month;

  double get remaining => allocated - spent;
  double get progress =>
      allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
  bool get isOverAllocated => spent > allocated;

  Envelope copyWith({
    String? id,
    String? name,
    double? allocated,
    double? spent,
    String? categoryId,
    int? year,
    int? month,
    bool clearCategoryId = false,
  }) {
    return Envelope(
      id: id ?? this.id,
      name: name ?? this.name,
      allocated: allocated ?? this.allocated,
      spent: spent ?? this.spent,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }
}

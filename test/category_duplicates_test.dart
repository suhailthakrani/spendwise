import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/category_duplicates.dart';
import 'package:spendwise/data/models/category.dart';

void main() {
  ExpenseCategory cat(String id, String name, {bool custom = false}) {
    return ExpenseCategory(
      id: id,
      name: name,
      iconName: 'category',
      color: const Color(0xFF000000),
      isCustom: custom,
    );
  }

  test('finds nested leftover names for merge banner', () {
    final pairs = findLikelyDuplicatePairs([
      cat('a', 'Gym', custom: true),
      cat('b', 'Gym fees', custom: true),
      cat('c', 'Fuel'),
    ]);
    expect(pairs.length, 1);
    expect(
      {pairs.first.left.name, pairs.first.right.name},
      {'Gym', 'Gym fees'},
    );
  });

  test('ignores unrelated categories', () {
    final pairs = findLikelyDuplicatePairs([
      cat('a', 'Fuel'),
      cat('b', 'Education'),
      cat('c', 'Pets'),
    ]);
    expect(pairs, isEmpty);
  });
}

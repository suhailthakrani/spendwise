import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/expenses/quick_add_logic.dart';

void main() {
  group('QuickAddLogic.applyKey', () {
    test('digits and backspace', () {
      expect(QuickAddLogic.applyKey('', '5'), '5');
      expect(QuickAddLogic.applyKey('5', '0'), '50');
      expect(QuickAddLogic.applyKey('50', 'backspace'), '5');
      expect(QuickAddLogic.applyKey('0', '7'), '7');
    });

    test('decimal handling', () {
      expect(QuickAddLogic.applyKey('12', '.'), '12.');
      expect(QuickAddLogic.applyKey('', '.'), '0.');
      expect(QuickAddLogic.applyKey('12.', '.'), '12.');
      expect(QuickAddLogic.applyKey('12.3', '4'), '12.34');
      expect(QuickAddLogic.applyKey('12.34', '5'), '12.34');
    });

    test('no decimals when decimalDigits is 0', () {
      expect(
        QuickAddLogic.applyKey('12', '.', decimalDigits: 0),
        '12',
      );
    });
  });

  group('QuickAddLogic.resolveCategoryId', () {
    test('prefers last used, then default, then first', () {
      const ids = ['a', 'b', 'c'];
      expect(
        QuickAddLogic.resolveCategoryId(
          rankedCategoryIds: ids,
          lastUsedCategoryId: 'b',
          defaultCategoryId: 'c',
        ),
        'b',
      );
      expect(
        QuickAddLogic.resolveCategoryId(
          rankedCategoryIds: ids,
          lastUsedCategoryId: 'missing',
          defaultCategoryId: 'c',
        ),
        'c',
      );
      expect(
        QuickAddLogic.resolveCategoryId(
          rankedCategoryIds: ids,
          lastUsedCategoryId: null,
          defaultCategoryId: null,
        ),
        'a',
      );
      expect(
        QuickAddLogic.resolveCategoryId(
          rankedCategoryIds: const [],
          lastUsedCategoryId: 'a',
          defaultCategoryId: 'b',
        ),
        isNull,
      );
    });
  });
}

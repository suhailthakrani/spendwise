import 'package:flutter/services.dart';

/// Restricts text to a non-negative amount with a fixed number of decimals.
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter({required this.decimalDigits})
      : assert(decimalDigits >= 0);

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '').trim();

    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    if (text.contains('-') || text.toLowerCase().contains('e')) {
      return oldValue;
    }

    if (decimalDigits <= 0) {
      if (!RegExp(r'^\d+$').hasMatch(text)) return oldValue;
      final normalized = text.replaceFirst(RegExp(r'^0+(?=\d)'), '');
      return _value(normalized, newValue, text);
    }

    if ('.'.allMatches(text).length > 1) return oldValue;
    if (!RegExp('^\\d*\\.?\\d{0,$decimalDigits}\$').hasMatch(text)) {
      return oldValue;
    }

    var normalized = text;
    if (normalized.startsWith('.')) {
      normalized = '0$normalized';
    }
    if (RegExp(r'^0\d').hasMatch(normalized)) {
      normalized = normalized.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    }

    return _value(normalized, newValue, text);
  }

  TextEditingValue _value(
    String normalized,
    TextEditingValue newValue,
    String cleanedInput,
  ) {
    if (normalized == newValue.text) return newValue;

    // Pasted commas / leading zeros: place caret at end.
    if (normalized != cleanedInput || cleanedInput != newValue.text) {
      return TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    return newValue.copyWith(text: normalized);
  }
}

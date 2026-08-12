import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/currency_display.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/export_format.dart';
import '../models/export_preview.dart';
import '../models/export_range.dart';
import '../repositories/category_repository.dart';
import '../repositories/expense_repository.dart';

class ExportService {
  ExportService({
    required ExpenseRepository expenseRepository,
    required CategoryRepository categoryRepository,
  })  : _expenses = expenseRepository,
        _categories = categoryRepository;

  final ExpenseRepository _expenses;
  final CategoryRepository _categories;

  static const _previewSampleSize = 25;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<ExportPreview> preview({
    required ExportDateRange range,
    required CurrencyDisplay currency,
  }) async {
    final (expenses, categories) = await _load(range, currency);
    return _buildPreview(expenses, categories, currency, range.displayLabel);
  }

  Future<ShareResult> exportAndShare({
    required ExportFormat format,
    required ExportDateRange range,
    required CurrencyDisplay currency,
  }) async {
    final (expenses, categories) = await _load(range, currency);
    final file = await _writeFile(
      format: format,
      expenses: expenses,
      categories: categories,
      currency: currency,
      rangeLabel: range.displayLabel,
    );

    return SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: format.mimeType,
            name: p.basename(file.path),
          ),
        ],
        subject: 'SpendWise expenses export',
        text: 'SpendWise ${format.label} export (${range.displayLabel})',
      ),
    );
  }

  Future<(List<Expense>, List<ExpenseCategory>)> _load(
    ExportDateRange range,
    CurrencyDisplay currency,
  ) async {
    final (start, end) = range.resolve();
    final expenses = await _expenses.search(
      startDate: start,
      endDate: end,
      toDisplayAmount: currency.toDisplayAmount,
    );
    final categories = await _categories.watchAll().first;
    return (expenses, categories);
  }

  ExportPreview _buildPreview(
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    CurrencyDisplay currency,
    String rangeLabel,
  ) {
    final byId = {for (final c in categories) c.id: c};
    final categoryTotals = <String, double>{};
    var total = 0.0;

    for (final e in expenses) {
      final display = currency.toDisplayAmount(e.amount);
      total += display;
      final name = byId[e.categoryId]?.name ?? 'Unknown';
      categoryTotals[name] = (categoryTotals[name] ?? 0) + display;
    }

    final sample = expenses.take(_previewSampleSize).map((e) {
      return ExportPreviewRow(
        date: e.date,
        amountDisplay: currency.toDisplayAmount(e.amount),
        categoryName: byId[e.categoryId]?.name ?? 'Unknown',
        note: e.note,
        paymentMethod: e.paymentMethod.label,
      );
    }).toList();

    final sortedTotals = Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return ExportPreview(
      rowCount: expenses.length,
      totalDisplay: total,
      currencyCode: currency.displayCurrencyCode,
      categoryTotals: sortedTotals,
      sampleRows: sample,
      rangeLabel: rangeLabel,
    );
  }

  Future<File> _writeFile({
    required ExportFormat format,
    required List<Expense> expenses,
    required List<ExpenseCategory> categories,
    required CurrencyDisplay currency,
    required String rangeLabel,
  }) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final name = 'spendwise_expenses_$stamp.${format.fileExtension}';
    final file = File(p.join(dir.path, name));

    switch (format) {
      case ExportFormat.csv:
        await file.writeAsString(
          _toCsv(expenses, categories, currency, rangeLabel),
        );
      case ExportFormat.excel:
        final bytes = _toExcel(expenses, categories, currency, rangeLabel);
        await file.writeAsBytes(bytes, flush: true);
    }

    return file;
  }

  List<List<String>> _headerAndRows(
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    CurrencyDisplay currency,
  ) {
    final byId = {for (final c in categories) c.id: c};
    final code = currency.displayCurrencyCode;

    final rows = <List<String>>[
      [
        'Date',
        'Amount ($code)',
        'Category',
        'Note',
        'Payment method',
        'Recurring',
      ],
    ];

    for (final e in expenses) {
      rows.add([
        _dateFmt.format(e.date),
        currency.toDisplayAmount(e.amount).toStringAsFixed(
              currency.decimalDigits,
            ),
        byId[e.categoryId]?.name ?? 'Unknown',
        e.note,
        e.paymentMethod.label,
        e.isRecurring ? 'Yes' : 'No',
      ]);
    }

    return rows;
  }

  String _toCsv(
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    CurrencyDisplay currency,
    String rangeLabel,
  ) {
    final rows = _headerAndRows(expenses, categories, currency);
    final meta = [
      ['SpendWise expense export'],
      ['Range', rangeLabel],
      ['Currency', currency.displayCurrencyCode],
      ['Rows', '${expenses.length}'],
      <String>[],
    ];
    return const ListToCsvConverter().convert([...meta, ...rows]);
  }

  List<int> _toExcel(
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    CurrencyDisplay currency,
    String rangeLabel,
  ) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    final sheet = excel['Expenses'];
    if (defaultSheet != null && defaultSheet != 'Expenses') {
      excel.delete(defaultSheet);
    }

    sheet.appendRow([
      TextCellValue('SpendWise expense export'),
    ]);
    sheet.appendRow([
      TextCellValue('Range'),
      TextCellValue(rangeLabel),
    ]);
    sheet.appendRow([
      TextCellValue('Currency'),
      TextCellValue(currency.displayCurrencyCode),
    ]);
    sheet.appendRow([
      TextCellValue('Rows'),
      IntCellValue(expenses.length),
    ]);
    sheet.appendRow([TextCellValue('')]);

    for (final row in _headerAndRows(expenses, categories, currency)) {
      sheet.appendRow(row.map(TextCellValue.new).toList());
    }

    final encoded = excel.encode();
    if (encoded == null) {
      throw StateError('Failed to encode Excel file');
    }
    return encoded;
  }
}

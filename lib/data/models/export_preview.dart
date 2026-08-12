class ExportPreviewRow {
  const ExportPreviewRow({
    required this.date,
    required this.amountDisplay,
    required this.categoryName,
    required this.note,
    required this.paymentMethod,
  });

  final DateTime date;
  final double amountDisplay;
  final String categoryName;
  final String note;
  final String paymentMethod;
}

class ExportPreview {
  const ExportPreview({
    required this.rowCount,
    required this.totalDisplay,
    required this.currencyCode,
    required this.categoryTotals,
    required this.sampleRows,
    required this.rangeLabel,
  });

  final int rowCount;
  final double totalDisplay;
  final String currencyCode;
  final Map<String, double> categoryTotals;
  final List<ExportPreviewRow> sampleRows;
  final String rangeLabel;

  bool get isEmpty => rowCount == 0;
}

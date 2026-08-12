enum ExportFormat {
  csv,
  excel;

  String get label => switch (this) {
        ExportFormat.csv => 'CSV',
        ExportFormat.excel => 'Excel',
      };

  String get fileExtension => switch (this) {
        ExportFormat.csv => 'csv',
        ExportFormat.excel => 'xlsx',
      };

  String get mimeType => switch (this) {
        ExportFormat.csv => 'text/csv',
        ExportFormat.excel =>
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      };
}

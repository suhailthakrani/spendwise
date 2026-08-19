enum ExportFormat {
  excel;

  String get label => 'Excel';

  String get fileExtension => 'xlsx';

  String get mimeType =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
}

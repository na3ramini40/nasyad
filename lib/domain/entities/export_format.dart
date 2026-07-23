enum ExportFormat {
  json,
  csv,
  plainText,
}

extension ExportFormatX on ExportFormat {
  String get fileExtension => switch (this) {
        ExportFormat.json => 'json',
        ExportFormat.csv => 'csv',
        ExportFormat.plainText => 'txt',
      };

  String get mimeType => switch (this) {
        ExportFormat.json => 'application/json',
        ExportFormat.csv => 'text/csv',
        ExportFormat.plainText => 'text/plain',
      };
}

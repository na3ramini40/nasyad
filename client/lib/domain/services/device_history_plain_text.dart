import 'package:nasyad/domain/entities/device_history_share.dart';

String renderDeviceHistoryPlainText(
  DeviceHistoryShareDocument document, {
  required String Function(DateTime date) formatDate,
  required String Function(double cost, String? currencyLabel) formatCost,
}) {
  final buffer = StringBuffer()
    ..writeln(document.title)
    ..writeln();
  _writeNode(
    buffer,
    document.root,
    depth: 0,
    formatDate: formatDate,
    formatCost: formatCost,
  );
  return buffer.toString().trimRight();
}

void _writeNode(
  StringBuffer buffer,
  DeviceHistoryShareNode node, {
  required int depth,
  required String Function(DateTime date) formatDate,
  required String Function(double cost, String? currencyLabel) formatCost,
}) {
  final indent = '  ' * depth;
  buffer.writeln('$indent${node.name}');
  final location = node.locationLabel;
  if (location != null) {
    buffer.writeln('$indent  $location');
  }
  final description = node.description;
  if (description != null) {
    buffer.writeln('$indent  $description');
  }
  for (final line in node.lines) {
    final parts = <String>[formatDate(line.date)];
    final notes = line.notes;
    if (notes != null) parts.add(notes);
    final vendor = line.vendor;
    if (vendor != null) parts.add(vendor);
    final cost = line.cost;
    if (cost != null) parts.add(formatCost(cost, line.costCurrency));
    buffer.writeln('$indent  - ${parts.join(' · ')}');
  }
  for (final child in node.children) {
    buffer.writeln();
    _writeNode(
      buffer,
      child,
      depth: depth + 1,
      formatDate: formatDate,
      formatCost: formatCost,
    );
  }
}

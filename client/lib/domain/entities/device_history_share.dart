import 'package:equatable/equatable.dart';

class DeviceHistoryShareLine extends Equatable {
  final DateTime date;
  final String? notes;
  final String? vendor;
  final double? cost;
  final String? costCurrency;

  const DeviceHistoryShareLine({
    required this.date,
    this.notes,
    this.vendor,
    this.cost,
    this.costCurrency,
  });

  @override
  List<Object?> get props => [date, notes, vendor, cost, costCurrency];
}

class DeviceHistoryShareNode extends Equatable {
  final String name;
  final String? locationLabel;
  final String? description;
  final List<DeviceHistoryShareLine> lines;
  final List<DeviceHistoryShareNode> children;

  const DeviceHistoryShareNode({
    required this.name,
    this.locationLabel,
    this.description,
    this.lines = const [],
    this.children = const [],
  });

  bool get hasMaintenance {
    if (lines.isNotEmpty) return true;
    for (final child in children) {
      if (child.hasMaintenance) return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [
    name,
    locationLabel,
    description,
    lines,
    children,
  ];
}

class DeviceHistoryShareDocument extends Equatable {
  final DeviceHistoryShareNode root;
  final String title;

  const DeviceHistoryShareDocument({required this.root, required this.title});

  bool get hasMaintenance => root.hasMaintenance;

  @override
  List<Object?> get props => [root, title];
}

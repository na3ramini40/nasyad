import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatLogCost(Locale locale, double cost, {String? currencyLabel}) {
  final label = currencyLabel?.trim();
  if (label != null && label.isNotEmpty) {
    final formatted = NumberFormat('#,##0.##', locale.toString()).format(cost);
    return '$formatted $label';
  }
  return NumberFormat.simpleCurrency(locale: locale.toString()).format(cost);
}

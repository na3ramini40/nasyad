import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/utils/log_cost_formatter.dart';

void main() {
  test('formatLogCost uses locale currency when label empty', () {
    final formatted = formatLogCost(const Locale('en', 'US'), 49.99);
    expect(formatted, contains('49.99'));
    expect(formatted, contains('\$'));
  });

  test('formatLogCost uses custom currency label when provided', () {
    final formatted = formatLogCost(
      const Locale('en', 'US'),
      1200,
      currencyLabel: 'IRR',
    );
    expect(formatted, '1,200 IRR');
  });
}

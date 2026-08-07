import 'package:flutter/material.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/app_bottom_sheet.dart';
import 'package:nasyad/core/ui/app_button.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/services/month_day.dart';

class MonthDayPickerField extends StatelessWidget {
  const MonthDayPickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.pickerTitle,
    required this.monthLabel,
    required this.dayLabel,
    required this.confirmLabel,
    required this.calendarSystem,
    required this.persianLabels,
    required this.onChanged,
    this.month,
    this.day,
    this.errorText,
  });

  final String label;
  final String hintText;
  final String pickerTitle;
  final String monthLabel;
  final String dayLabel;
  final String confirmLabel;
  final CalendarSystem calendarSystem;
  final bool persianLabels;
  final int? month;
  final int? day;
  final String? errorText;
  final void Function(int month, int day) onChanged;

  String? get _displayValue {
    if (month == null || day == null) return null;
    final names = MonthDay.monthNames(
      calendarSystem,
      persianLabels: persianLabels,
    );
    return '${names[month! - 1]} $day';
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showAppBottomSheet<(int, int)>(
      context: context,
      title: pickerTitle,
      builder: (context) {
        return _MonthDayPickerSheet(
          initialMonth: month ?? 1,
          initialDay: day ?? 1,
          calendarSystem: calendarSystem,
          persianLabels: persianLabels,
          monthLabel: monthLabel,
          dayLabel: dayLabel,
          confirmLabel: confirmLabel,
        );
      },
    );
    if (result != null) {
      onChanged(result.$1, result.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              suffixIcon: const Icon(Icons.cake_outlined),
            ),
            child: Text(
              _displayValue ?? hintText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _displayValue == null
                    ? theme.hintColor
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthDayPickerSheet extends StatefulWidget {
  const _MonthDayPickerSheet({
    required this.initialMonth,
    required this.initialDay,
    required this.calendarSystem,
    required this.persianLabels,
    required this.monthLabel,
    required this.dayLabel,
    required this.confirmLabel,
  });

  final int initialMonth;
  final int initialDay;
  final CalendarSystem calendarSystem;
  final bool persianLabels;
  final String monthLabel;
  final String dayLabel;
  final String confirmLabel;

  @override
  State<_MonthDayPickerSheet> createState() => _MonthDayPickerSheetState();
}

class _MonthDayPickerSheetState extends State<_MonthDayPickerSheet> {
  late int _month = widget.initialMonth.clamp(1, 12);
  late int _day = widget.initialDay;

  List<String> get _monthNames => MonthDay.monthNames(
    widget.calendarSystem,
    persianLabels: widget.persianLabels,
  );

  int get _maxDay => MonthDay.daysInMonth(_month, widget.calendarSystem);

  @override
  void initState() {
    super.initState();
    _day = _day.clamp(1, _maxDay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.monthLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<int>(
          initialValue: _month,
          items: [
            for (var i = 1; i <= 12; i++)
              DropdownMenuItem(value: i, child: Text(_monthNames[i - 1])),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _month = value;
              _day = _day.clamp(
                1,
                MonthDay.daysInMonth(_month, widget.calendarSystem),
              );
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(widget.dayLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<int>(
          initialValue: _day.clamp(1, _maxDay),
          items: [
            for (var i = 1; i <= _maxDay; i++)
              DropdownMenuItem(value: i, child: Text('$i')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _day = value);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: widget.confirmLabel,
          onPressed: () => Navigator.of(context).pop((_month, _day)),
        ),
      ],
    );
  }
}

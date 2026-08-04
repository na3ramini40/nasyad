import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/presentation/birthday/bloc/birthday_edit_bloc.dart';

class BirthdayEditPage extends StatefulWidget {
  const BirthdayEditPage({super.key, this.birthdayId});

  final String? birthdayId;

  bool get isEdit => birthdayId != null;

  @override
  State<BirthdayEditPage> createState() => _BirthdayEditPageState();
}

class _BirthdayEditPageState extends State<BirthdayEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncName(BirthdayEditState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
    }
  }

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteBirthdayTitle),
          content: Text(l10n.deleteBirthdayBody(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<BirthdayEditBloc>().add(const BirthdayEditDeleteRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preferredCalendar = context.watch<CalendarSystemCubit>().state;
    final persianLabels = Localizations.localeOf(context).languageCode == 'fa';

    return BlocConsumer<BirthdayEditBloc, BirthdayEditState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == BirthdayEditStatus.saved ||
            state.status == BirthdayEditStatus.deleted) {
          context.pop();
        }
      },
      builder: (context, state) {
        _syncName(state);
        final isBusy =
            state.status == BirthdayEditStatus.loading ||
            state.status == BirthdayEditStatus.saving;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: isBusy ? null : () => context.pop(),
              tooltip: l10n.back,
            ),
            title: Text(widget.isEdit ? l10n.editBirthday : l10n.addBirthday),
            actions: [
              if (widget.isEdit)
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: isBusy
                      ? null
                      : () => _confirmDelete(context, state.name),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: AppContent(
            child: state.status == BirthdayEditStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: l10n.personName,
                          hintText: l10n.personNameHint,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => context
                              .read<BirthdayEditBloc>()
                              .add(BirthdayEditNameChanged(value)),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.personNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MonthDayPickerField(
                          label: l10n.birthMonthDay,
                          hintText: l10n.birthMonthDayHint,
                          pickerTitle: l10n.pickMonthDay,
                          monthLabel: l10n.month,
                          dayLabel: l10n.day,
                          confirmLabel: l10n.confirm,
                          calendarSystem: preferredCalendar,
                          persianLabels: persianLabels,
                          month: state.birthMonth,
                          day: state.birthDay,
                          errorText:
                              state.errorMessage == l10n.birthMonthDayRequired
                              ? state.errorMessage
                              : null,
                          onChanged: (month, day) {
                            context.read<BirthdayEditBloc>().add(
                              BirthdayEditMonthDayChanged(
                                month: month,
                                day: day,
                                calendarSystem: preferredCalendar,
                              ),
                            );
                          },
                        ),
                        if (state.errorMessage != null &&
                            state.errorMessage !=
                                l10n.birthMonthDayRequired) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: l10n.save,
                          isLoading: state.status == BirthdayEditStatus.saving,
                          onPressed: isBusy
                              ? null
                              : () {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  context.read<BirthdayEditBloc>().add(
                                    BirthdayEditSaveRequested(
                                      nameRequiredMessage:
                                          l10n.personNameRequired,
                                      monthDayRequiredMessage:
                                          l10n.birthMonthDayRequired,
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

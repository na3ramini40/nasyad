import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/services/month_day.dart';
import 'package:nasyad/presentation/birthday/bloc/birthday_list_bloc.dart';

class BirthdayListPage extends StatelessWidget {
  const BirthdayListPage({super.key});

  Future<void> _confirmDelete(BuildContext context, Birthday birthday) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteBirthdayTitle),
          content: Text(l10n.deleteBirthdayBody(birthday.name)),
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
      context.read<BirthdayListBloc>().add(
        BirthdayListDeleteRequested(birthday.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final calendar = context.watch<CalendarSystemCubit>().state;
    final persianLabels = Localizations.localeOf(context).languageCode == 'fa';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: l10n.back,
        ),
        title: Text(l10n.birthdays),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/birthdays/new'),
        tooltip: l10n.addBirthday,
        child: const Icon(Icons.add),
      ),
      body: AppContent(
        child: BlocBuilder<BirthdayListBloc, BirthdayListState>(
          builder: (context, state) {
            return switch (state) {
              BirthdayListInitial() || BirthdayListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              BirthdayListError(:final message) => Center(child: Text(message)),
              BirthdayListLoaded(:final birthdays) when birthdays.isEmpty =>
                _EmptyBirthdays(l10n: l10n),
              BirthdayListLoaded(:final birthdays) => ListView.separated(
                itemCount: birthdays.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final birthday = birthdays[index];
                  final dateLabel = MonthDay.format(
                    birthday.birthMonth,
                    birthday.birthDay,
                    birthday.calendarSystem,
                    displayCalendar: calendar,
                    persianLabels: persianLabels,
                  );
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.cake_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(birthday.name),
                      subtitle: Text(dateLabel),
                      trailing: IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, birthday),
                      ),
                      onTap: () =>
                          context.push('/birthdays/${birthday.id}/edit'),
                    ),
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }
}

class _EmptyBirthdays extends StatelessWidget {
  const _EmptyBirthdays({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cake_outlined,
              size: 48,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noBirthdaysTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noBirthdaysHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.addBirthday,
              expand: false,
              onPressed: () => context.push('/birthdays/new'),
            ),
          ],
        ),
      ),
    );
  }
}

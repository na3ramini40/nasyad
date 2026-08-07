import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/presentation/app_update/widgets/app_update_banner.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/presentation/app_update/bloc/app_update_bloc.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';
import 'package:nasyad/presentation/home/widgets/device_reminder_quick_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _whatsNewChecked = false;
  var _updateCheckStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_whatsNewChecked) return;
    _whatsNewChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _onFirstFrame());
  }

  Future<void> _onFirstFrame() async {
    if (!mounted) return;
    await _checkWhatsNew();
    if (!mounted) return;
    _startBackgroundUpdateCheck();
  }

  void _startBackgroundUpdateCheck() {
    if (_updateCheckStarted) return;
    _updateCheckStarted = true;
    context.read<AppUpdateBloc>().add(
      const AppUpdateCheckRequested(background: true),
    );
  }

  Future<void> _checkWhatsNew() async {
    if (!mounted) return;
    final store = AppServicesScope.of(context).lastSeenVersionStore;
    await maybeShowWhatsNewOnLaunch(
      context,
      readLastSeen: store.read,
      writeLastSeen: store.write,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo.mark(height: 28),
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: Text(l10n.appTitle)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/preferences'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.preferences,
          ),
        ],
      ),
      body: AppContent(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() ||
              HomeLoading() => const Center(child: CircularProgressIndicator()),
              HomeError(:final message) => Center(child: Text(message)),
              HomeLoaded(:final filter) => _HomeBody(
                l10n: l10n,
                filter: filter,
                reminders: state.visibleReminders,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.l10n,
    required this.filter,
    required this.reminders,
  });

  final AppLocalizations l10n;
  final HomeReminderFilter filter;
  final List<HomeReminder> reminders;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const AppUpdateBanner(),
        SectionHeader(title: l10n.remindersSection),
        _ReminderFilters(l10n: l10n, selected: filter),
        const SizedBox(height: AppSpacing.sm),
        if (reminders.isEmpty)
          _EmptyReminders(l10n: l10n)
        else
          ...reminders.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ReminderListItem(
                title: item.title,
                subtitle: _reminderSubtitle(l10n, item),
                badgeLabel: _reminderBadgeLabel(l10n, item),
                badgeVariant: _reminderBadgeVariant(item),
                icon: item.kind == HomeReminderKind.device
                    ? Icons.devices_other
                    : Icons.cake_outlined,
                onTap: () => _openReminder(context, item),
                onQuickActions: item.kind == HomeReminderKind.device
                    ? () => showDeviceReminderQuickActions(
                        context: context,
                        deviceId: item.deviceId!,
                        deviceName: item.title,
                      )
                    : null,
                quickActionsTooltip: item.kind == HomeReminderKind.device
                    ? l10n.reminderQuickActionsMenu
                    : null,
              ),
            ),
          ),
        SectionHeader(title: l10n.featuresSection),
        FeatureMenuTile(
          title: l10n.deviceManagement,
          subtitle: l10n.deviceManagementHint,
          icon: Icons.devices_other,
          onTap: () => context.push('/devices'),
        ),
        const SizedBox(height: AppSpacing.sm),
        FeatureMenuTile(
          title: l10n.birthdays,
          subtitle: l10n.birthdaysFeatureHint,
          icon: Icons.cake_outlined,
          onTap: () => context.push('/birthdays'),
        ),
      ],
    );
  }

  void _openReminder(BuildContext context, HomeReminder item) {
    switch (item.kind) {
      case HomeReminderKind.device:
        context.push('/device/${item.deviceId}');
      case HomeReminderKind.birthday:
        context.push('/birthdays/${item.birthdayId}/edit');
    }
  }

  String _reminderSubtitle(AppLocalizations l10n, HomeReminder item) {
    return switch (item.kind) {
      HomeReminderKind.device => switch (item.deviceStatus) {
        MaintenanceStatus.due => l10n.reminderDeviceDue,
        MaintenanceStatus.soon => l10n.reminderDeviceSoon,
        _ => l10n.reminderDeviceSoon,
      },
      HomeReminderKind.birthday => switch (item.daysUntilBirthday) {
        0 => l10n.reminderBirthdayToday,
        1 => l10n.reminderBirthdayTomorrow,
        final days? => l10n.reminderBirthdayInDays(days),
        null => l10n.birthdays,
      },
    };
  }

  String _reminderBadgeLabel(AppLocalizations l10n, HomeReminder item) {
    return switch (item.urgency) {
      HomeReminderUrgency.due => l10n.reminderBadgeDue,
      HomeReminderUrgency.soon => l10n.reminderBadgeSoon,
      HomeReminderUrgency.upcoming => l10n.reminderBadgeUpcoming,
    };
  }

  StatusBadgeVariant _reminderBadgeVariant(HomeReminder item) {
    return switch (item.urgency) {
      HomeReminderUrgency.due => StatusBadgeVariant.warning,
      HomeReminderUrgency.soon => StatusBadgeVariant.neutral,
      HomeReminderUrgency.upcoming => StatusBadgeVariant.success,
    };
  }
}

class _ReminderFilters extends StatelessWidget {
  const _ReminderFilters({required this.l10n, required this.selected});

  final AppLocalizations l10n;
  final HomeReminderFilter selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.reminderFilterAll,
            selected: selected == HomeReminderFilter.all,
            onTap: () => context.read<HomeBloc>().add(
              const HomeFilterChanged(HomeReminderFilter.all),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: l10n.reminderFilterDevices,
            selected: selected == HomeReminderFilter.devices,
            onTap: () => context.read<HomeBloc>().add(
              const HomeFilterChanged(HomeReminderFilter.devices),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: l10n.reminderFilterBirthdays,
            selected: selected == HomeReminderFilter.birthdays,
            onTap: () => context.read<HomeBloc>().add(
              const HomeFilterChanged(HomeReminderFilter.birthdays),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = selected
        ? scheme.secondary.withValues(alpha: 0.12)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.45);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.noRemindersTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.noRemindersHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

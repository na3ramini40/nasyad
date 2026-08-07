import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_radius.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/search_results.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/services/month_day.dart';
import 'package:nasyad/presentation/search/bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    context.read<SearchBloc>().add(SearchQueryChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: l10n.back,
        ),
        title: Text(l10n.search),
      ),
      body: AppContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _controller,
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
              onSubmitted: _onQueryChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchInitial() => _SearchPrompt(l10n: l10n),
                    SearchLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    SearchError(:final message) => Center(child: Text(message)),
                    SearchLoaded(:final results) when results.isEmpty =>
                      _SearchNoResults(l10n: l10n),
                    SearchLoaded(:final results) => _SearchResultsList(
                      l10n: l10n,
                      results: results,
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.l10n});

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
            Icon(Icons.search, size: 48, color: theme.colorScheme.secondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.searchPromptTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.searchPromptHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchNoResults extends StatelessWidget {
  const _SearchNoResults({required this.l10n});

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
              Icons.search_off_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.searchNoResultsTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.searchNoResultsHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.l10n, required this.results});

  final AppLocalizations l10n;
  final SearchResults results;

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarSystemCubit>().state;
    final persianLabels = Localizations.localeOf(context).languageCode == 'fa';

    return ListView(
      children: [
        if (results.devices.isNotEmpty) ...[
          SectionHeader(title: l10n.searchDevicesSection),
          ...results.devices.map(
            (hit) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SearchResultTile(
                title: hit.device.name,
                subtitle: _devicePathLabel(l10n, hit.pathSegments),
                icon: Icons.devices_other,
                onTap: () => context.push('/device/${hit.device.id}'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (results.birthdays.isNotEmpty) ...[
          SectionHeader(title: l10n.searchBirthdaysSection),
          ...results.birthdays.map(
            (birthday) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SearchResultTile(
                title: birthday.name,
                subtitle: _birthdayDateLabel(birthday, calendar, persianLabels),
                icon: Icons.cake_outlined,
                onTap: () => context.push('/birthdays/${birthday.id}/edit'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _devicePathLabel(AppLocalizations l10n, List<String> segments) {
    if (segments.length <= 1) return l10n.deviceManagement;
    return segments.join(l10n.searchPathSeparator);
  }

  String _birthdayDateLabel(
    Birthday birthday,
    CalendarSystem calendar,
    bool persianLabels,
  ) {
    return MonthDay.format(
      birthday.birthMonth,
      birthday.birthDay,
      birthday.calendarSystem,
      displayCalendar: calendar,
      persianLabels: persianLabels,
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: scheme.secondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

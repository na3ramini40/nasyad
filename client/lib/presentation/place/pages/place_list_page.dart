import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/presentation/place/bloc/place_list_bloc.dart';

class PlaceListPage extends StatelessWidget {
  const PlaceListPage({super.key});

  Future<void> _confirmDelete(BuildContext context, Place place) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deletePlaceTitle),
          content: Text(l10n.deletePlaceBody(place.name)),
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
      context.read<PlaceListBloc>().add(PlaceListDeleteRequested(place.id));
    }
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
        title: Text(l10n.places),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/places/new'),
        tooltip: l10n.addPlace,
        child: const Icon(Icons.add),
      ),
      body: AppContent(
        child: BlocBuilder<PlaceListBloc, PlaceListState>(
          builder: (context, state) {
            return switch (state) {
              PlaceListInitial() || PlaceListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              PlaceListError(:final message) => Center(child: Text(message)),
              PlaceListLoaded(:final places) when places.isEmpty =>
                _EmptyPlaces(l10n: l10n),
              PlaceListLoaded(:final places) => ListView.separated(
                itemCount: places.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        _iconForKind(place.kind),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(place.name),
                      subtitle: Text(_subtitle(l10n, place)),
                      trailing: IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, place),
                      ),
                      onTap: () => context.push('/places/${place.id}/edit'),
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

  IconData _iconForKind(PlaceGeometryKind kind) {
    return switch (kind) {
      PlaceGeometryKind.point => Icons.place_outlined,
      PlaceGeometryKind.line => Icons.timeline,
      PlaceGeometryKind.polygon => Icons.pentagon_outlined,
    };
  }

  String _subtitle(AppLocalizations l10n, Place place) {
    return switch (place.kind) {
      PlaceGeometryKind.point when place.points.isNotEmpty =>
        l10n.placeCoordinateSummary(
          place.points.first.latitude,
          place.points.first.longitude,
        ),
      PlaceGeometryKind.line => l10n.placeKindLineWithCount(
        place.points.length,
      ),
      PlaceGeometryKind.polygon => l10n.placeKindAreaWithCount(
        place.points.length,
      ),
      _ => l10n.placeKindPoint,
    };
  }
}

class _EmptyPlaces extends StatelessWidget {
  const _EmptyPlaces({required this.l10n});

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
              Icons.map_outlined,
              size: 48,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noPlacesTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noPlacesHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.addPlace,
              expand: false,
              onPressed: () => context.push('/places/new'),
            ),
          ],
        ),
      ),
    );
  }
}

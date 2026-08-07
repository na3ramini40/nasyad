import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/presentation/place/bloc/place_edit_bloc.dart';
import 'package:nasyad/presentation/place/widgets/place_map_canvas.dart';

class PlaceEditPage extends StatefulWidget {
  const PlaceEditPage({super.key, this.placeId, this.initialKind});

  final String? placeId;
  final PlaceGeometryKind? initialKind;

  @override
  State<PlaceEditPage> createState() => _PlaceEditPageState();
}

class _PlaceEditPageState extends State<PlaceEditPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deletePlaceTitle),
          content: Text(l10n.deletePlaceBody(_nameController.text)),
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
      context.read<PlaceEditBloc>().add(const PlaceEditDeleteRequested());
    }
  }

  String _mapHint(AppLocalizations l10n, PlaceEditState state) {
    return switch (state.kind) {
      PlaceGeometryKind.point => l10n.placeMapHintPoint,
      PlaceGeometryKind.line => l10n.placeMapHintLine(state.points.length),
      PlaceGeometryKind.polygon =>
        l10n.placeMapHintArea(state.points.length),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.placeId != null;

    return BlocConsumer<PlaceEditBloc, PlaceEditState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.name != current.name ||
          previous.locationDenied != current.locationDenied,
      listener: (context, state) {
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }

        if (state.locationDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.placeLocationDenied)),
          );
        }

        switch (state.status) {
          case PlaceEditStatus.saved:
            context.pop();
          case PlaceEditStatus.deleted:
            context.pop();
          case PlaceEditStatus.failure:
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          default:
            break;
        }
      },
      builder: (context, state) {
        final saving = state.status == PlaceEditStatus.saving;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: saving ? null : () => context.pop(),
              tooltip: l10n.back,
            ),
            title: Text(isEdit ? l10n.editPlace : l10n.addPlace),
            actions: [
              if (isEdit)
                IconButton(
                  onPressed: saving ? null : () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.delete,
                ),
              TextButton(
                onPressed: saving || !state.canSave
                    ? null
                    : () => context.read<PlaceEditBloc>().add(
                        PlaceEditSaveRequested(
                          nameRequiredMessage: l10n.placeNameRequired,
                          geometryRequiredMessage: l10n.placeGeometryRequired,
                        ),
                      ),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
          body: switch (state.status) {
            PlaceEditStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            _ => Column(
              children: [
                Expanded(
                  child: AppContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: l10n.placeName,
                          hint: l10n.placeNameHint,
                          onChanged: (value) => context.read<PlaceEditBloc>().add(
                            PlaceEditNameChanged(value),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _KindSelector(
                          selected: state.kind,
                          onChanged: (kind) => context.read<PlaceEditBloc>().add(
                            PlaceEditKindChanged(kind),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: PlaceMapCanvas(
                            kind: state.kind,
                            points: state.points,
                            hint: _mapHint(l10n, state),
                            onTap: (point) => context.read<PlaceEditBloc>().add(
                              PlaceEditMapTapped(point),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  elevation: 8,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => context.read<PlaceEditBloc>().add(
                                      const PlaceEditUseCurrentLocationRequested(),
                                    ),
                              icon: const Icon(Icons.my_location),
                              label: Text(l10n.placeUseMyLocation),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving || !state.canUndoPoint
                                  ? null
                                  : () => context.read<PlaceEditBloc>().add(
                                      const PlaceEditUndoPointRequested(),
                                    ),
                              icon: const Icon(Icons.undo),
                              label: Text(l10n.placeUndoPoint),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          },
        );
      },
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.selected, required this.onChanged});

  final PlaceGeometryKind selected;
  final ValueChanged<PlaceGeometryKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<PlaceGeometryKind>(
      segments: [
        ButtonSegment(
          value: PlaceGeometryKind.point,
          label: Text(l10n.placeKindPoint),
          icon: const Icon(Icons.place_outlined),
        ),
        ButtonSegment(
          value: PlaceGeometryKind.line,
          label: Text(l10n.placeKindLine),
          icon: const Icon(Icons.timeline),
        ),
        ButtonSegment(
          value: PlaceGeometryKind.polygon,
          label: Text(l10n.placeKindArea),
          icon: const Icon(Icons.pentagon_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

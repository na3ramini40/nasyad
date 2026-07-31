import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/transfer/bloc/transfer_bloc.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<TransferBloc, TransferState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.errorMessage != null &&
            state.status == TransferStatus.failure) {
          messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<TransferBloc>().add(const TransferFeedbackCleared());
          return;
        }

        final message = switch (state.feedback) {
          TransferFeedback.exportShared => l10n.exportSuccess,
          TransferFeedback.exportCopied => l10n.exportCopied,
          TransferFeedback.exportSaved => l10n.exportSaved(
            state.feedbackDetail ?? '',
          ),
          TransferFeedback.importSuccess => l10n.importSuccess(
            int.tryParse(state.feedbackDetail ?? '') ?? 0,
          ),
          TransferFeedback.none => null,
        };
        if (message != null) {
          messenger.showSnackBar(SnackBar(content: Text(message)));
          context.read<TransferBloc>().add(const TransferFeedbackCleared());
        }
      },
      builder: (context, state) {
        final bloc = context.read<TransferBloc>();
        final noDevicesMessage = state.devices.isEmpty
            ? l10n.noDevicesForExport
            : l10n.exportNoDevices;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
              tooltip: l10n.back,
            ),
            title: Text(l10n.exportImport),
          ),
          body: AppContent(
            child: ListView(
              children: [
                SectionHeader(title: l10n.exportSection),
                Text(
                  l10n.exportScope,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SelectableOptionTile(
                  label: l10n.exportScopeAll,
                  selected: state.scope == ExportScopeKind.all,
                  onTap: () =>
                      bloc.add(const TransferScopeChanged(ExportScopeKind.all)),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableOptionTile(
                  label: l10n.exportScopeOne,
                  selected: state.scope == ExportScopeKind.one,
                  onTap: () =>
                      bloc.add(const TransferScopeChanged(ExportScopeKind.one)),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableOptionTile(
                  label: l10n.exportScopeSelected,
                  selected: state.scope == ExportScopeKind.selected,
                  onTap: () => bloc.add(
                    const TransferScopeChanged(ExportScopeKind.selected),
                  ),
                ),
                if (state.scope != ExportScopeKind.all) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.selectDevices,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.status == TransferStatus.loadingDevices)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.devices.isEmpty)
                    Text(l10n.noDevicesForExport)
                  else
                    ...state.devices.map((device) {
                      final selected = state.selectedIds.contains(device.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: SelectableOptionTile(
                          label: device.name,
                          selected: selected,
                          onTap: () =>
                              bloc.add(TransferDeviceToggled(device.id)),
                        ),
                      );
                    }),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.exportFormat,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SelectableOptionTile(
                  label: l10n.formatJson,
                  selected: state.format == ExportFormat.json,
                  onTap: () =>
                      bloc.add(const TransferFormatChanged(ExportFormat.json)),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableOptionTile(
                  label: l10n.formatCsv,
                  selected: state.format == ExportFormat.csv,
                  onTap: () =>
                      bloc.add(const TransferFormatChanged(ExportFormat.csv)),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableOptionTile(
                  label: l10n.formatPlainText,
                  selected: state.format == ExportFormat.plainText,
                  onTap: () => bloc.add(
                    const TransferFormatChanged(ExportFormat.plainText),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: l10n.share,
                        icon: Icons.share_outlined,
                        variant: AppButtonVariant.secondary,
                        isLoading: state.status == TransferStatus.busy,
                        onPressed: state.canExport
                            ? () => bloc.add(
                                TransferShareRequested(
                                  noDevicesMessage: noDevicesMessage,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: l10n.saveFile,
                        icon: Icons.save_outlined,
                        isLoading: state.status == TransferStatus.busy,
                        onPressed: state.canExport
                            ? () => bloc.add(
                                TransferSaveRequested(
                                  noDevicesMessage: noDevicesMessage,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: l10n.importSection),
                AppButton(
                  label: l10n.chooseFile,
                  icon: Icons.folder_open_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: state.isBusy
                      ? null
                      : () => bloc.add(
                          TransferPickImportRequested(
                            invalidFileMessage: l10n.importInvalid,
                          ),
                        ),
                ),
                if (state.importPreview != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.importPreview(
                      state.importPreview!.deviceCount,
                      state.importPreview!.logCount,
                    ),
                  ),
                  if (state.importFileName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      state.importFileName!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.importAction,
                    icon: Icons.download_outlined,
                    isLoading: state.status == TransferStatus.busy,
                    onPressed: () => bloc.add(
                      TransferImportConfirmed(
                        invalidFileMessage: l10n.importInvalid,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}

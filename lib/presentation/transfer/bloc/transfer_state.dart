part of 'transfer_bloc.dart';

enum TransferStatus {
  initial,
  loadingDevices,
  ready,
  busy,
  failure,
}

enum TransferFeedback {
  none,
  exportShared,
  exportCopied,
  exportSaved,
  importSuccess,
}

final class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.initial,
    this.devices = const [],
    this.scope = ExportScopeKind.all,
    this.format = ExportFormat.json,
    this.selectedIds = const {},
    this.importPreview,
    this.importFileName,
    this.importContent,
    this.feedback = TransferFeedback.none,
    this.feedbackDetail,
    this.errorMessage,
  });

  final TransferStatus status;
  final List<Device> devices;
  final ExportScopeKind scope;
  final ExportFormat format;
  final Set<String> selectedIds;
  final ExportBundle? importPreview;
  final String? importFileName;
  final String? importContent;
  final TransferFeedback feedback;
  final String? feedbackDetail;
  final String? errorMessage;

  bool get isBusy =>
      status == TransferStatus.busy || status == TransferStatus.loadingDevices;

  bool get canExport {
    if (isBusy) return false;
    return switch (scope) {
      ExportScopeKind.all => devices.isNotEmpty,
      ExportScopeKind.one => selectedIds.length == 1,
      ExportScopeKind.selected => selectedIds.isNotEmpty,
    };
  }

  List<String> get exportIds => switch (scope) {
        ExportScopeKind.all => const [],
        ExportScopeKind.one || ExportScopeKind.selected =>
          selectedIds.toList(),
      };

  TransferState copyWith({
    TransferStatus? status,
    List<Device>? devices,
    ExportScopeKind? scope,
    ExportFormat? format,
    Set<String>? selectedIds,
    ExportBundle? importPreview,
    String? importFileName,
    String? importContent,
    TransferFeedback? feedback,
    String? feedbackDetail,
    String? errorMessage,
    bool clearImport = false,
    bool clearFeedback = false,
    bool clearError = false,
  }) {
    return TransferState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      scope: scope ?? this.scope,
      format: format ?? this.format,
      selectedIds: selectedIds ?? this.selectedIds,
      importPreview: clearImport ? null : (importPreview ?? this.importPreview),
      importFileName:
          clearImport ? null : (importFileName ?? this.importFileName),
      importContent:
          clearImport ? null : (importContent ?? this.importContent),
      feedback: clearFeedback ? TransferFeedback.none : (feedback ?? this.feedback),
      feedbackDetail:
          clearFeedback ? null : (feedbackDetail ?? this.feedbackDetail),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        devices,
        scope,
        format,
        selectedIds,
        importPreview,
        importFileName,
        importContent,
        feedback,
        feedbackDetail,
        errorMessage,
      ];
}

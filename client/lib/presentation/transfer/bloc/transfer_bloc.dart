import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/transfer_file_actions.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/usecases/device/get_all_devices_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required GetAllDevicesUsecase getAllDevices,
    required ExportDataUsecase exportData,
    required ImportDataUsecase importData,
    TransferFileActions fileActions = const TransferFileActions(),
  }) : _getAllDevices = getAllDevices,
       _exportData = exportData,
       _importData = importData,
       _fileActions = fileActions,
       super(const TransferState()) {
    on<TransferStarted>(_onStarted);
    on<TransferScopeChanged>(_onScopeChanged);
    on<TransferFormatChanged>(_onFormatChanged);
    on<TransferDeviceToggled>(_onDeviceToggled);
    on<TransferShareRequested>(_onShare);
    on<TransferSaveRequested>(_onSave);
    on<TransferPickImportRequested>(_onPickImport);
    on<TransferImportConfirmed>(_onImportConfirmed);
    on<TransferFeedbackCleared>(_onFeedbackCleared);
  }

  final GetAllDevicesUsecase _getAllDevices;
  final ExportDataUsecase _exportData;
  final ImportDataUsecase _importData;
  final TransferFileActions _fileActions;

  Future<void> _onStarted(
    TransferStarted event,
    Emitter<TransferState> emit,
  ) async {
    emit(
      state.copyWith(status: TransferStatus.loadingDevices, clearError: true),
    );
    try {
      final devices = await _getAllDevices();
      emit(state.copyWith(status: TransferStatus.ready, devices: devices));
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onScopeChanged(
    TransferScopeChanged event,
    Emitter<TransferState> emit,
  ) {
    var selected = Set<String>.from(state.selectedIds);
    if (event.scope == ExportScopeKind.all) {
      selected.clear();
    } else if (event.scope == ExportScopeKind.one && selected.length > 1) {
      final first = selected.first;
      selected = {first};
    }
    emit(state.copyWith(scope: event.scope, selectedIds: selected));
  }

  void _onFormatChanged(
    TransferFormatChanged event,
    Emitter<TransferState> emit,
  ) {
    emit(state.copyWith(format: event.format));
  }

  void _onDeviceToggled(
    TransferDeviceToggled event,
    Emitter<TransferState> emit,
  ) {
    final selected = Set<String>.from(state.selectedIds);
    if (state.scope == ExportScopeKind.one) {
      emit(state.copyWith(selectedIds: {event.deviceId}));
      return;
    }
    if (selected.contains(event.deviceId)) {
      selected.remove(event.deviceId);
    } else {
      selected.add(event.deviceId);
    }
    emit(state.copyWith(selectedIds: selected));
  }

  Future<void> _onShare(
    TransferShareRequested event,
    Emitter<TransferState> emit,
  ) async {
    final result = await _buildExport(emit, event.noDevicesMessage);
    if (result == null) return;

    emit(state.copyWith(status: TransferStatus.busy, clearError: true));
    try {
      final outcome = await _fileActions.share(
        content: result.content,
        fileName: result.fileName,
        format: result.format,
      );
      emit(
        state.copyWith(
          status: TransferStatus.ready,
          feedback: outcome == TransferShareOutcome.copiedToClipboard
              ? TransferFeedback.exportCopied
              : TransferFeedback.exportShared,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSave(
    TransferSaveRequested event,
    Emitter<TransferState> emit,
  ) async {
    final result = await _buildExport(emit, event.noDevicesMessage);
    if (result == null) return;

    emit(state.copyWith(status: TransferStatus.busy, clearError: true));
    try {
      final path = await _fileActions.save(
        content: result.content,
        fileName: result.fileName,
        format: result.format,
      );
      if (path == null) {
        emit(state.copyWith(status: TransferStatus.ready));
        return;
      }
      emit(
        state.copyWith(
          status: TransferStatus.ready,
          feedback: TransferFeedback.exportSaved,
          feedbackDetail: path,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<ExportDataResult?> _buildExport(
    Emitter<TransferState> emit,
    String noDevicesMessage,
  ) async {
    if (!state.canExport) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: noDevicesMessage,
        ),
      );
      return null;
    }

    emit(state.copyWith(status: TransferStatus.busy, clearError: true));
    try {
      return await _exportData(
        scope: state.scope,
        format: state.format,
        deviceIds: state.exportIds,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      return null;
    }
  }

  Future<void> _onPickImport(
    TransferPickImportRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.busy, clearError: true));
    try {
      final picked = await _fileActions.pickImportFile();
      if (picked == null) {
        emit(state.copyWith(status: TransferStatus.ready));
        return;
      }
      final preview = _importData.preview(
        picked.content,
        fileName: picked.name,
      );
      emit(
        state.copyWith(
          status: TransferStatus.ready,
          importContent: picked.content,
          importFileName: picked.name,
          importPreview: preview,
        ),
      );
    } on BundleCodecException catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: error.message,
          clearImport: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: event.invalidFileMessage,
          clearImport: true,
        ),
      );
    }
  }

  Future<void> _onImportConfirmed(
    TransferImportConfirmed event,
    Emitter<TransferState> emit,
  ) async {
    final content = state.importContent;
    if (content == null) return;

    emit(state.copyWith(status: TransferStatus.busy, clearError: true));
    try {
      final result = await _importData(content, fileName: state.importFileName);
      final devices = await _getAllDevices();
      emit(
        state.copyWith(
          status: TransferStatus.ready,
          devices: devices,
          feedback: TransferFeedback.importSuccess,
          importSuccessDevices: result.bundle.deviceCount,
          importSuccessBirthdays: result.bundle.birthdayCount,
          importSuccessPlaces: result.bundle.placeCount,
          clearImport: true,
        ),
      );
    } on BundleCodecException catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransferStatus.failure,
          errorMessage: event.invalidFileMessage,
        ),
      );
    }
  }

  void _onFeedbackCleared(
    TransferFeedbackCleared event,
    Emitter<TransferState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true, clearError: true));
  }
}

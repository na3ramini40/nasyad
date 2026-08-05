import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/data/services/app_update_service_impl.dart';
import 'package:nasyad/domain/entities/app_release.dart';
import 'package:nasyad/domain/services/app_update_service.dart';

part 'app_update_event.dart';
part 'app_update_state.dart';

class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateState> {
  AppUpdateBloc({AppUpdateService? appUpdateService})
    : _service = appUpdateService ?? AppUpdateServiceImpl(),
      super(const AppUpdateInitial()) {
    on<AppUpdateCheckRequested>(_onCheckRequested);
    on<AppUpdateDownloadRequested>(_onDownloadRequested);
    on<AppUpdateInstallRequested>(_onInstallRequested);
    on<AppUpdateBannerDismissed>(_onBannerDismissed);
    on<AppUpdateErrorDismissed>(_onErrorDismissed);
  }

  final AppUpdateService _service;

  Future<void> _onCheckRequested(
    AppUpdateCheckRequested event,
    Emitter<AppUpdateState> emit,
  ) async {
    emit(AppUpdateChecking(manual: !event.background));
    final result = await _service.checkForUpdate();

    switch (result.status) {
      case AppUpdateCheckStatus.upToDate:
        emit(AppUpdateUpToDate(manual: !event.background));
      case AppUpdateCheckStatus.unsupportedPlatform:
        emit(AppUpdateUnsupported(manual: !event.background));
      case AppUpdateCheckStatus.failed:
        emit(
          AppUpdateError(
            message: result.errorMessage ?? 'Update check failed',
            manual: !event.background,
          ),
        );
      case AppUpdateCheckStatus.updateAvailable:
        final release = result.release!;
        emit(
          AppUpdateAvailable(
            release: release,
            showBanner: event.background,
            manual: !event.background,
          ),
        );
    }
  }

  Future<void> _onDownloadRequested(
    AppUpdateDownloadRequested event,
    Emitter<AppUpdateState> emit,
  ) async {
    final current = state;
    final release = switch (current) {
      AppUpdateAvailable(:final release) => release,
      AppUpdateError(:final release) when release != null => release,
      _ => null,
    };
    if (release == null) return;

    try {
      await for (final progress in _service.downloadUpdate(release)) {
        emit(AppUpdateDownloading(release: release, progress: progress));
      }
      final localPath = await _service.localPathFor(release);
      emit(AppUpdateReadyToInstall(release: release, localPath: localPath));
    } catch (error) {
      emit(
        AppUpdateError(
          message: error.toString(),
          manual: true,
          release: release,
        ),
      );
    }
  }

  Future<void> _onInstallRequested(
    AppUpdateInstallRequested event,
    Emitter<AppUpdateState> emit,
  ) async {
    final current = state;
    if (current is! AppUpdateReadyToInstall) return;

    try {
      await _service.installUpdate(current.release, current.localPath);
    } catch (error) {
      emit(
        AppUpdateError(
          message: error.toString(),
          manual: true,
          release: current.release,
        ),
      );
    }
  }

  void _onBannerDismissed(
    AppUpdateBannerDismissed event,
    Emitter<AppUpdateState> emit,
  ) {
    final current = state;
    if (current is AppUpdateAvailable) {
      emit(
        AppUpdateAvailable(
          release: current.release,
          showBanner: false,
          manual: current.manual,
        ),
      );
    }
  }

  void _onErrorDismissed(
    AppUpdateErrorDismissed event,
    Emitter<AppUpdateState> emit,
  ) {
    emit(const AppUpdateInitial());
  }
}

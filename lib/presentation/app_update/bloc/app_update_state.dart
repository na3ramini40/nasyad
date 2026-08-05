part of 'app_update_bloc.dart';

sealed class AppUpdateState extends Equatable {
  const AppUpdateState();

  @override
  List<Object?> get props => [];
}

final class AppUpdateInitial extends AppUpdateState {
  const AppUpdateInitial();
}

final class AppUpdateChecking extends AppUpdateState {
  const AppUpdateChecking({this.manual = false});

  final bool manual;

  @override
  List<Object?> get props => [manual];
}

final class AppUpdateUpToDate extends AppUpdateState {
  const AppUpdateUpToDate({this.manual = false});

  final bool manual;

  @override
  List<Object?> get props => [manual];
}

final class AppUpdateUnsupported extends AppUpdateState {
  const AppUpdateUnsupported({this.manual = false});

  final bool manual;

  @override
  List<Object?> get props => [manual];
}

final class AppUpdateAvailable extends AppUpdateState {
  const AppUpdateAvailable({
    required this.release,
    this.showBanner = false,
    this.manual = false,
  });

  final AppRelease release;
  final bool showBanner;
  final bool manual;

  @override
  List<Object?> get props => [release, showBanner, manual];
}

final class AppUpdateDownloading extends AppUpdateState {
  const AppUpdateDownloading({required this.release, required this.progress});

  final AppRelease release;
  final DownloadProgress progress;

  @override
  List<Object?> get props => [release, progress];
}

final class AppUpdateReadyToInstall extends AppUpdateState {
  const AppUpdateReadyToInstall({
    required this.release,
    required this.localPath,
  });

  final AppRelease release;
  final String localPath;

  @override
  List<Object?> get props => [release, localPath];
}

final class AppUpdateError extends AppUpdateState {
  const AppUpdateError({
    required this.message,
    this.manual = false,
    this.release,
  });

  final String message;
  final bool manual;
  final AppRelease? release;

  @override
  List<Object?> get props => [message, manual, release];
}

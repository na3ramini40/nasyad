part of 'app_update_bloc.dart';

sealed class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => [];
}

final class AppUpdateCheckRequested extends AppUpdateEvent {
  const AppUpdateCheckRequested({this.background = false});

  final bool background;

  @override
  List<Object?> get props => [background];
}

final class AppUpdateDownloadRequested extends AppUpdateEvent {
  const AppUpdateDownloadRequested();
}

final class AppUpdateInstallRequested extends AppUpdateEvent {
  const AppUpdateInstallRequested();
}

final class AppUpdateBannerDismissed extends AppUpdateEvent {
  const AppUpdateBannerDismissed();
}

final class AppUpdateErrorDismissed extends AppUpdateEvent {
  const AppUpdateErrorDismissed();
}

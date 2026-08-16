part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({required this.allReminders, required this.filter});

  final List<HomeReminder> allReminders;
  final HomeReminderFilter filter;

  List<HomeReminder> get visibleReminders {
    return switch (filter) {
      HomeReminderFilter.all => allReminders,
      HomeReminderFilter.devices =>
        allReminders
            .where(
              (item) =>
                  item.kind == HomeReminderKind.device ||
                  item.kind == HomeReminderKind.tag,
            )
            .toList(growable: false),
      HomeReminderFilter.birthdays =>
        allReminders
            .where((item) => item.kind == HomeReminderKind.birthday)
            .toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [allReminders, filter];
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

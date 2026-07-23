import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashReady extends SplashState {
  const SplashReady();
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({this.minDisplay = const Duration(milliseconds: 1200)})
    : super(const SplashLoading());

  final Duration minDisplay;

  Future<void> start() async {
    emit(const SplashLoading());
    await Future<void>.delayed(minDisplay);
    if (!isClosed) emit(const SplashReady());
  }
}

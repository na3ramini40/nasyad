import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/usecases/auth/has_completed_intro_usecase.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashReady extends SplashState {
  const SplashReady({required this.showIntro});

  final bool showIntro;

  @override
  List<Object?> get props => [showIntro];
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required HasCompletedIntroUsecase hasCompletedIntro,
    this.minDisplay = const Duration(milliseconds: 1200),
  }) : _hasCompletedIntro = hasCompletedIntro,
       super(const SplashLoading());

  final HasCompletedIntroUsecase _hasCompletedIntro;
  final Duration minDisplay;

  Future<void> start() async {
    emit(const SplashLoading());
    final results = await Future.wait<Object?>([
      Future<void>.delayed(minDisplay),
      _hasCompletedIntro(),
    ]);
    final introDone = results[1] as bool;
    if (!isClosed) {
      emit(SplashReady(showIntro: !introDone));
    }
  }
}

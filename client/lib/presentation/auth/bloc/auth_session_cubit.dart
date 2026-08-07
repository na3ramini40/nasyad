import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/usecases/auth/watch_auth_session_usecase.dart';

class AuthSessionCubit extends Cubit<AuthSession> {
  AuthSessionCubit({
    required WatchAuthSessionUsecase watchAuthSession,
    AuthSession initial = AuthSession.guest,
  }) : _watchAuthSession = watchAuthSession,
       super(initial) {
    _subscription = _watchAuthSession().listen(emit);
  }

  final WatchAuthSessionUsecase _watchAuthSession;
  StreamSubscription<AuthSession>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

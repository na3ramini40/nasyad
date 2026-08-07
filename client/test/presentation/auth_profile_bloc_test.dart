import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/sync_preference_store.dart';
import 'package:nasyad/core/sync/network_status_reader.dart';
import 'package:nasyad/domain/entities/auth_session.dart';
import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/domain/services/local_sync_coordinator.dart';
import 'package:nasyad/domain/services/remote_sync_port.dart';
import 'package:nasyad/domain/usecases/auth/get_profile_usecase.dart';
import 'package:nasyad/domain/usecases/auth/has_completed_intro_usecase.dart';
import 'package:nasyad/domain/usecases/auth/request_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/resend_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/sign_out_usecase.dart';
import 'package:nasyad/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:nasyad/domain/usecases/auth/watch_auth_session_usecase.dart';
import 'package:nasyad/presentation/auth/bloc/auth_flow_bloc.dart';
import 'package:nasyad/presentation/profile/bloc/profile_bloc.dart';
import 'package:nasyad/presentation/splash/bloc/splash_cubit.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  group('SplashCubit', () {
    test('routes to intro when intro not completed', () async {
      final repo = FakeAuthRepository(introCompleted: false);
      final cubit = SplashCubit(
        hasCompletedIntro: HasCompletedIntroUsecase(repo),
        minDisplay: Duration.zero,
      );
      await cubit.start();
      expect(cubit.state, isA<SplashReady>());
      expect((cubit.state as SplashReady).showIntro, isTrue);
      await cubit.close();
      repo.dispose();
    });

    test('skips intro when already completed', () async {
      final repo = FakeAuthRepository(introCompleted: true);
      final cubit = SplashCubit(
        hasCompletedIntro: HasCompletedIntroUsecase(repo),
        minDisplay: Duration.zero,
      );
      await cubit.start();
      expect((cubit.state as SplashReady).showIntro, isFalse);
      await cubit.close();
      repo.dispose();
    });
  });

  group('AuthFlowBloc', () {
    AuthFlowBloc buildBloc(
      FakeAuthRepository repo, {
      LocalSyncCoordinator? syncCoordinator,
    }) {
      return AuthFlowBloc(
        requestOtp: RequestOtpUsecase(repo),
        resendOtp: ResendOtpUsecase(repo),
        verifyOtp: VerifyOtpUsecase(repo),
        authRepository: repo,
        syncCoordinator: syncCoordinator,
        tickInterval: const Duration(hours: 1),
      );
    }

    Future<void> reachOtp(AuthFlowBloc bloc) async {
      bloc.add(const AuthPhoneChanged('09121234567'));
      bloc.add(const AuthSendCodeRequested());
      await bloc.stream.firstWhere((s) => s.step == AuthFlowStep.otp);
    }

    test('send code moves to otp step and starts cooldown', () async {
      final repo = FakeAuthRepository();
      final bloc = buildBloc(repo);

      bloc.add(const AuthPhoneChanged('09121234567'));
      bloc.add(const AuthSendCodeRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthFlowState>(
            (s) =>
                s.step == AuthFlowStep.otp &&
                s.cooldownSeconds == 120 &&
                s.normalizedPhone == '+989121111111',
          ),
        ),
      );

      expect(repo.requestOtpCalls, 1);
      expect(repo.lastPhone, '+989121234567');
      await bloc.close();
      repo.dispose();
    });

    test('rejects invalid phone without calling API', () async {
      final repo = FakeAuthRepository();
      final bloc = buildBloc(repo);

      bloc.add(const AuthPhoneChanged('12'));
      bloc.add(const AuthSendCodeRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthFlowState>(
            (s) =>
                s.status == AuthFlowStatus.failure &&
                s.errorMessage == 'invalid_phone',
          ),
        ),
      );
      expect(repo.requestOtpCalls, 0);
      await bloc.close();
      repo.dispose();
    });

    test('verify success emits success status', () async {
      final repo = FakeAuthRepository();
      final bloc = buildBloc(repo);

      await reachOtp(bloc);

      bloc.add(const AuthCodeChanged('123456'));
      bloc.add(const AuthVerifyRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthFlowState>((s) => s.status == AuthFlowStatus.success),
        ),
      );
      expect(repo.verifyOtpCalls, 1);
      expect(repo.currentSession.isSignedIn, isTrue);
      await bloc.close();
      repo.dispose();
    });

    test('after verify invokes sync and emits syncing then success', () async {
      final repo = FakeAuthRepository();
      final prefs = SyncPreferenceStore.memory();
      final port = _CountingSyncPort();
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: port,
      );
      final bloc = buildBloc(repo, syncCoordinator: coordinator);

      await reachOtp(bloc);
      bloc.add(const AuthCodeChanged('123456'));
      bloc.add(const AuthVerifyRequested());

      final statuses = <AuthFlowStatus>[];
      final sub = bloc.stream.listen((s) => statuses.add(s.status));
      await bloc.stream.firstWhere(
        (s) => s.status == AuthFlowStatus.success && !s.syncFailed,
      );
      await sub.cancel();

      expect(statuses, contains(AuthFlowStatus.syncing));
      expect(statuses.last, AuthFlowStatus.success);
      expect(port.detectCalls, greaterThanOrEqualTo(1));
      expect(port.syncCalls, 1);
      expect(port.lastToken, 'token-1');
      await bloc.close();
      prefs.dispose();
      repo.dispose();
    });

    test('sync failure still yields success with syncFailed', () async {
      final repo = FakeAuthRepository();
      final prefs = SyncPreferenceStore.memory();
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: _FailingSyncPort(),
      );
      final bloc = buildBloc(repo, syncCoordinator: coordinator);

      await reachOtp(bloc);
      bloc.add(const AuthCodeChanged('123456'));
      bloc.add(const AuthVerifyRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthFlowState>(
            (s) => s.status == AuthFlowStatus.success && s.syncFailed,
          ),
        ),
      );
      expect(repo.currentSession.isSignedIn, isTrue);
      await bloc.close();
      prefs.dispose();
      repo.dispose();
    });

    test('conflicts → awaiting confirm; confirm continues sync', () async {
      final repo = FakeAuthRepository();
      final prefs = SyncPreferenceStore.memory();
      final port = _ConflictThenOkPort();
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: port,
      );
      final bloc = buildBloc(repo, syncCoordinator: coordinator);

      await reachOtp(bloc);
      bloc.add(const AuthCodeChanged('123456'));
      bloc.add(const AuthVerifyRequested());

      await bloc.stream.firstWhere(
        (s) => s.status == AuthFlowStatus.awaitingSyncConfirm,
      );
      expect(bloc.state.syncConflictTotal, 2);
      expect(port.syncCalls, 0);

      bloc.add(const AuthSyncOverrideConfirmed());
      await bloc.stream.firstWhere(
        (s) => s.status == AuthFlowStatus.success && !s.syncFailed,
      );
      expect(port.syncCalls, 1);
      expect(port.lastOverrideConfirmed, isTrue);
      await bloc.close();
      prefs.dispose();
      repo.dispose();
    });

    test('conflicts cancel → success without override sync', () async {
      final repo = FakeAuthRepository();
      final prefs = SyncPreferenceStore.memory();
      final port = _ConflictThenOkPort();
      final coordinator = LocalSyncCoordinator(
        preferenceStore: prefs,
        networkStatus: const AlwaysOnlineNetworkStatus(),
        remoteEngine: port,
      );
      final bloc = buildBloc(repo, syncCoordinator: coordinator);

      await reachOtp(bloc);
      bloc.add(const AuthCodeChanged('123456'));
      bloc.add(const AuthVerifyRequested());

      await bloc.stream.firstWhere(
        (s) => s.status == AuthFlowStatus.awaitingSyncConfirm,
      );

      bloc.add(const AuthSyncOverrideCancelled());
      await bloc.stream.firstWhere(
        (s) =>
            s.status == AuthFlowStatus.success &&
            s.syncCancelled &&
            !s.syncFailed,
      );
      expect(port.syncCalls, 0);
      expect(repo.currentSession.isSignedIn, isTrue);
      await bloc.close();
      prefs.dispose();
      repo.dispose();
    });

    test('resend stays disabled while cooldown remains', () async {
      final repo = FakeAuthRepository();
      final bloc = buildBloc(repo);

      await reachOtp(bloc);

      bloc.add(const AuthResendRequested());
      await pumpEventQueue();
      expect(repo.resendOtpCalls, 0);
      expect(bloc.state.canResend, isFalse);
      await bloc.close();
      repo.dispose();
    });
  });

  group('ProfileBloc', () {
    final sampleProfile = UserProfile(
      id: 'hash',
      phone: '+989121234567',
      name: 'Ada',
      imageUrl: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    test('guest state exposes sign-in empty profile', () async {
      final repo = FakeAuthRepository();
      final bloc = ProfileBloc(
        watchAuthSession: WatchAuthSessionUsecase(repo),
        getProfile: GetProfileUsecase(repo),
        signOut: SignOutUsecase(repo),
      )..add(const ProfileStarted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (s) => s.isGuest && s.status == ProfileStatus.ready,
          ),
        ),
      );
      await bloc.close();
      repo.dispose();
    });

    test('signed-in session shows profile and sign-out clears it', () async {
      final repo = FakeAuthRepository(
        initial: AuthSession(token: 't', profile: sampleProfile),
      );
      final bloc = ProfileBloc(
        watchAuthSession: WatchAuthSessionUsecase(repo),
        getProfile: GetProfileUsecase(repo),
        signOut: SignOutUsecase(repo),
      )..add(const ProfileStarted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ProfileState>(
            (s) => !s.isGuest && s.session.profile?.name == 'Ada',
          ),
        ),
      );

      bloc.add(const ProfileSignOutRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<ProfileState>((s) => s.isGuest)),
      );
      expect(repo.signOutCalls, 1);
      await bloc.close();
      repo.dispose();
    });
  });
}

class _CountingSyncPort implements RemoteSyncPort {
  var detectCalls = 0;
  var syncCalls = 0;
  String? lastToken;

  @override
  Future<SyncConflictSummary> detectConflicts({required String token}) async {
    detectCalls += 1;
    lastToken = token;
    return const SyncConflictSummary();
  }

  @override
  Future<void> sync({
    required String token,
    bool overrideConfirmed = false,
  }) async {
    syncCalls += 1;
    lastToken = token;
  }
}

class _FailingSyncPort implements RemoteSyncPort {
  @override
  Future<SyncConflictSummary> detectConflicts({required String token}) async {
    return const SyncConflictSummary();
  }

  @override
  Future<void> sync({
    required String token,
    bool overrideConfirmed = false,
  }) async {
    throw StateError('sync failed');
  }
}

class _ConflictThenOkPort implements RemoteSyncPort {
  var syncCalls = 0;
  bool? lastOverrideConfirmed;

  @override
  Future<SyncConflictSummary> detectConflicts({required String token}) async {
    return const SyncConflictSummary(deviceCount: 1, birthdayCount: 1);
  }

  @override
  Future<void> sync({
    required String token,
    bool overrideConfirmed = false,
  }) async {
    if (!overrideConfirmed) {
      throw const SyncOverrideRequiredException(
        SyncConflictSummary(deviceCount: 1, birthdayCount: 1),
      );
    }
    syncCalls += 1;
    lastOverrideConfirmed = overrideConfirmed;
  }
}

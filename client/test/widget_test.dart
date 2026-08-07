import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/calendar/calendar_preference_store.dart';
import 'package:nasyad/core/notifications/reminder_notification_preference_store.dart';
import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/core/theme/app_breakpoints.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/theme/season_theme_cubit.dart';
import 'package:nasyad/core/theme/season_theme_preference_store.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/core/theme/theme_mode_preference_store.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/core/version/last_seen_version_store.dart';
import 'package:nasyad/data/local/auth_session_store.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/main.dart';
import 'package:nasyad/presentation/splash/bloc/splash_cubit.dart';

import 'sqlite_test_setup.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => LocaleCubit(initialLocale: locale)),
      BlocProvider(
        create: (_) => ThemeModeCubit(store: ThemeModePreferenceStore.memory()),
      ),
      BlocProvider(
        create: (_) =>
            SeasonThemeCubit(store: SeasonThemePreferenceStore.memory()),
      ),
      BlocProvider(
        create: (_) =>
            CalendarSystemCubit(store: CalendarPreferenceStore.memory()),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: child,
    ),
  );
}

Future<AppServices> _testServices() {
  return AppServices.createForTests(
    AppDatabase(NativeDatabase.memory()),
    lastSeenVersionStore: LastSeenVersionStore.memory(),
    calendarPreferenceStore: CalendarPreferenceStore.memory(),
    seasonThemePreferenceStore: SeasonThemePreferenceStore.memory(),
    themeModePreferenceStore: ThemeModePreferenceStore.memory(),
    reminderNotificationPreferenceStore:
        ReminderNotificationPreferenceStore.memory(),
    soonWindowPreferenceStore: SoonWindowPreferenceStore.memory(),
    reminderSnoozeStore: ReminderSnoozeStore.memory(),
  );
}

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1300));
  await tester.pumpAndSettle();
}

Future<void> _pumpApp(WidgetTester tester, AppServices services) async {
  await tester.pumpWidget(MyApp(services: services));
  await _pumpPastSplash(tester);
}

Future<void> _disposeApp(WidgetTester tester, AppServices services) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  services.reminderSnoozeStore.dispose();
  services.soonWindowPreferenceStore.dispose();
  await services.dispose();
}

void main() {
  setUpAll(setupSqliteForTests);

  testWidgets('splash navigates to home empty state', (tester) async {
    final services = await _testServices();

    await _pumpApp(tester, services);

    expect(find.text('Nothing needs attention'), findsOneWidget);
    expect(find.text('Features'), findsOneWidget);
    expect(find.text('Device management'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    await _disposeApp(tester, services);
  });

  testWidgets('preferences switches language to persian', (tester) async {
    final services = await _testServices();

    await _pumpApp(tester, services);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);
    await tester.tap(find.text('Language & region'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Persian'));
    await tester.pumpAndSettle();

    expect(find.text('تنظیمات'), findsOneWidget);
    expect(find.text('فارسی'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('نصیاد'), findsOneWidget);
    expect(find.text('مورد فوری نیست'), findsOneWidget);

    await _disposeApp(tester, services);
  });

  testWidgets('preferences can select dark theme', (tester) async {
    final services = await _testServices();

    await _pumpApp(tester, services);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    final appearance = find.text('Appearance');
    await tester.scrollUntilVisible(
      appearance,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(appearance);
    await tester.pumpAndSettle();
    final dark = find.text('Dark');
    await tester.scrollUntilVisible(
      dark,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(dark);
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    await _disposeApp(tester, services);
  });

  test('SplashCubit emits ready after delay', () async {
    final services = await _testServices();
    final cubit = SplashCubit(
      hasCompletedIntro: services.hasCompletedIntro,
      minDisplay: Duration.zero,
    );
    expect(cubit.state, isA<SplashLoading>());
    await cubit.start();
    expect(cubit.state, isA<SplashReady>());
    expect((cubit.state as SplashReady).showIntro, isFalse);
    await cubit.close();
    await services.dispose();
  });

  testWidgets('splash shows intro when first install', (tester) async {
    final services = await AppServices.createForTests(
      AppDatabase(NativeDatabase.memory()),
      lastSeenVersionStore: LastSeenVersionStore.memory(),
      calendarPreferenceStore: CalendarPreferenceStore.memory(),
      seasonThemePreferenceStore: SeasonThemePreferenceStore.memory(),
      themeModePreferenceStore: ThemeModePreferenceStore.memory(),
      reminderNotificationPreferenceStore:
          ReminderNotificationPreferenceStore.memory(),
      soonWindowPreferenceStore: SoonWindowPreferenceStore.memory(),
      reminderSnoozeStore: ReminderSnoozeStore.memory(),
      authSessionStore: AuthSessionStore.memory(introCompleted: false),
    );

    await tester.pumpWidget(MyApp(services: services));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Nasyad'), findsOneWidget);
    expect(find.text('Sign in with phone'), findsOneWidget);
    expect(find.text('Continue offline'), findsOneWidget);

    await tester.tap(find.text('Continue offline'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing needs attention'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await _disposeApp(tester, services);
  });

  testWidgets('profile tab shows guest sign-in CTA', (tester) async {
    final services = await _testServices();

    await _pumpApp(tester, services);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('You’re signed out'), findsOneWidget);
    expect(find.text('Sign in with phone'), findsOneWidget);

    await _disposeApp(tester, services);
  });

  testWidgets('StatusBadge variants render labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Scaffold(
          body: Row(
            children: [
              StatusBadge.success(label: 'Up to Date'),
              StatusBadge.warning(label: 'Maintenance Due'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Up to Date'), findsOneWidget);
    expect(find.text('Maintenance Due'), findsOneWidget);
  });

  testWidgets('AppButton invokes onPressed', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: AppButton(label: 'Save', onPressed: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    expect(tapped, isTrue);
  });

  testWidgets('DeviceCard switches to grid on wide screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: AppContent(
            child: ResponsiveBuilder(
              builder: (context, windowSize) {
                final columns = AppBreakpoints.deviceGridColumns(windowSize);
                return Text('columns:$columns');
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('columns:3'), findsOneWidget);
  });
}

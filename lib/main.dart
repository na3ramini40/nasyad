import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/locale_cubit.dart';
import 'package:nasyad/core/notifications/reminder_notification_cubit.dart';
import 'package:nasyad/core/deep_link/deep_link_handler.dart';
import 'package:nasyad/core/deep_link/deep_link_resolver.dart';
import 'package:nasyad/core/platform/firebase_platform.dart';
import 'package:nasyad/core/router/app_router.dart';
import 'package:nasyad/core/preferences/soon_window_cubit.dart';
import 'package:nasyad/core/theme/app_fonts.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/theme/season_theme_cubit.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/services/local_reminder_notification_service.dart';
import 'package:nasyad/data/services/push_notification_service.dart';
import 'package:nasyad/domain/entities/season_theme.dart';
import 'package:nasyad/firebase_messaging_background.dart';
import 'package:nasyad/firebase_options.dart';
import 'package:nasyad/l10n/app_localizations.dart';
import 'package:nasyad/presentation/app_update/bloc/app_update_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isFirebaseSupportedPlatform) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
  } else if (LocalReminderNotificationService.isSupported) {
    await PushNotificationService.ensureLocalNotificationsReady();
  }

  final database = AppDatabase();
  final services = AppServices(database);
  await services.localReminderScheduler.start();
  runApp(MyApp(services: services));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.services});

  final AppServices services;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = createAppRouter();
  late final DeepLinkHandler _deepLinkHandler = DeepLinkHandler(router: _router)
    ..install();

  @override
  void initState() {
    super.initState();
    PushNotificationService.onNotificationPayloadTapped =
        _onNotificationPayload;
    _openInitialNotificationTarget();
  }

  void _onNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final location = DeepLinkResolver.resolveLocationFromString(payload);
    if (location != null) {
      _router.go(location);
      return;
    }
    _deepLinkHandler.handleUri(Uri.parse(payload));
  }

  Future<void> _openInitialNotificationTarget() async {
    if (!LocalReminderNotificationService.isSupported) return;
    try {
      await PushNotificationService.ensureLocalNotificationsReady();
      final details = await PushNotificationService.localNotificationsPlugin
          .getNotificationAppLaunchDetails();
      final payload = details?.notificationResponse?.payload;
      if (details?.didNotificationLaunchApp == true && payload != null) {
        _onNotificationPayload(payload);
      }
    } catch (_) {
      // Notification plugins are unavailable in widget tests and some shells.
    }
  }

  @override
  void dispose() {
    PushNotificationService.onNotificationPayloadTapped = null;
    _deepLinkHandler.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: widget.services,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocaleCubit()),
          BlocProvider(
            create: (_) =>
                ThemeModeCubit(store: widget.services.themeModePreferenceStore),
          ),
          BlocProvider(
            create: (_) => SeasonThemeCubit(
              store: widget.services.seasonThemePreferenceStore,
            ),
          ),
          BlocProvider(
            create: (_) => CalendarSystemCubit(
              store: widget.services.calendarPreferenceStore,
            ),
          ),
          BlocProvider(
            create: (_) => SoonWindowCubit(
              store: widget.services.soonWindowPreferenceStore,
            ),
          ),
          BlocProvider(
            create: (_) => AppUpdateBloc(
              appUpdateService: widget.services.appUpdateService,
            ),
          ),
          BlocProvider(
            create: (_) => ReminderNotificationCubit(
              store: widget.services.reminderNotificationPreferenceStore,
              scheduler: widget.services.localReminderScheduler,
            ),
          ),
        ],
        child: BlocListener<LocaleCubit, Locale>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, locale) {
            widget.services.localReminderScheduler.setLocale(locale);
            widget.services.localReminderScheduler.reschedule();
          },
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return BlocBuilder<ThemeModeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return BlocBuilder<SeasonThemeCubit, SeasonTheme>(
                    builder: (context, seasonTheme) {
                      final fontFamily = AppFonts.familyForLocale(locale);
                      return MaterialApp.router(
                        onGenerateTitle: (context) =>
                            AppLocalizations.of(context).appTitle,
                        theme: AppTheme.lightTheme(
                          season: seasonTheme,
                          fontFamily: fontFamily,
                        ),
                        darkTheme: AppTheme.darkTheme(
                          season: seasonTheme,
                          fontFamily: fontFamily,
                        ),
                        themeMode: themeMode,
                        locale: locale,
                        supportedLocales: AppLocales.supported,
                        localeResolutionCallback: AppLocales.resolve,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        routerConfig: _router,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

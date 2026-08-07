import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/deep_link/deep_link_handler.dart';
import 'package:nasyad/core/platform/firebase_platform.dart';
import 'package:nasyad/core/router/app_router.dart';
import 'package:nasyad/core/preferences/soon_window_cubit.dart';
import 'package:nasyad/core/theme/app_fonts.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/theme/season_theme_cubit.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/services/push_notification_service.dart';
import 'package:nasyad/domain/entities/season_theme.dart';
import 'package:nasyad/firebase_messaging_background.dart';
import 'package:nasyad/firebase_options.dart';
import 'package:nasyad/presentation/app_update/bloc/app_update_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isFirebaseSupportedPlatform) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
  }

  final database = AppDatabase();
  final services = AppServices(database);
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
  void dispose() {
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
        ],
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
    );
  }
}

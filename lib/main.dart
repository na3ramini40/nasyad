import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/router/app_router.dart';
import 'package:nasyad/core/theme/app_fonts.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/theme/theme_mode_cubit.dart';
import 'package:nasyad/data/local/db/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void dispose() {
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
          BlocProvider(create: (_) => ThemeModeCubit()),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeModeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final fontFamily = AppFonts.familyForLocale(locale);
                return MaterialApp.router(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appTitle,
                  theme: AppTheme.lightTheme(fontFamily: fontFamily),
                  darkTheme: AppTheme.darkTheme(fontFamily: fontFamily),
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
        ),
      ),
    );
  }
}

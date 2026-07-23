import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/presentation/device/bloc/device_detail_bloc.dart';
import 'package:nasyad/presentation/device/bloc/device_edit_bloc.dart';
import 'package:nasyad/presentation/device/bloc/device_log_bloc.dart';
import 'package:nasyad/presentation/device/pages/device_edit_page.dart';
import 'package:nasyad/presentation/device/pages/device_log.dart';
import 'package:nasyad/presentation/device/pages/device_view_page.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';
import 'package:nasyad/presentation/home/pages/home_page.dart';
import 'package:nasyad/presentation/preferences/pages/preferences_page.dart';
import 'package:nasyad/presentation/splash/bloc/splash_cubit.dart';
import 'package:nasyad/presentation/splash/pages/splash_page.dart';
import 'package:nasyad/presentation/transfer/bloc/transfer_bloc.dart';
import 'package:nasyad/presentation/transfer/pages/transfer_page.dart';

abstract final class AppRoutes {
  static const splash = 'splash';
  static const home = 'home';
  static const preferences = 'preferences';
  static const transfer = 'transfer';
  static const deviceNew = 'device_new';
  static const deviceView = 'device_view';
  static const deviceEdit = 'device_edit';
  static const deviceLog = 'device_log';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => SplashCubit()..start(),
            child: const SplashPage(),
          );
        },
      ),
      GoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) {
          final services = AppServicesScope.of(context);
          return BlocProvider(
            create: (_) =>
                HomeBloc(services.watchDeviceSummaries)
                  ..add(const HomeStarted()),
            child: const HomePage(),
          );
        },
        routes: [
          GoRoute(
            path: 'preferences',
            name: AppRoutes.preferences,
            builder: (context, state) => const PreferencesPage(),
            routes: [
              GoRoute(
                path: 'transfer',
                name: AppRoutes.transfer,
                builder: (context, state) {
                  final services = AppServicesScope.of(context);
                  return BlocProvider(
                    create: (_) => TransferBloc(
                      getAllDevices: services.getAllDevices,
                      exportData: services.exportData,
                      importData: services.importData,
                    )..add(const TransferStarted()),
                    child: const TransferPage(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/device/new',
        name: AppRoutes.deviceNew,
        builder: (context, state) {
          final services = AppServicesScope.of(context);
          return BlocProvider(
            create: (_) => DeviceEditBloc(
              getDevice: services.getDevice,
              getRulesForDevice: services.getRulesForDevice,
              createDevice: services.createDevice,
              updateDevice: services.updateDevice,
              deleteDevice: services.deleteDevice,
            )..add(const DeviceEditStarted()),
            child: const DeviceEditPage(),
          );
        },
      ),
      GoRoute(
        path: '/device/:id',
        name: AppRoutes.deviceView,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final services = AppServicesScope.of(context);
          return BlocProvider(
            create: (_) => DeviceDetailBloc(
              deviceId: id,
              watchDeviceSummaries: services.watchDeviceSummaries,
              watchLogsForDevice: services.watchLogsForDevice,
              archiveDevice: services.archiveDevice,
            )..add(const DeviceDetailStarted()),
            child: DevicePage(deviceId: id),
          );
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRoutes.deviceEdit,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final services = AppServicesScope.of(context);
              return BlocProvider(
                create: (_) => DeviceEditBloc(
                  deviceId: id,
                  getDevice: services.getDevice,
                  getRulesForDevice: services.getRulesForDevice,
                  createDevice: services.createDevice,
                  updateDevice: services.updateDevice,
                  deleteDevice: services.deleteDevice,
                )..add(const DeviceEditStarted()),
                child: DeviceEditPage(deviceId: id),
              );
            },
          ),
          GoRoute(
            path: 'log',
            name: AppRoutes.deviceLog,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final services = AppServicesScope.of(context);
              return BlocProvider(
                create: (_) => DeviceLogBloc(
                  deviceId: id,
                  createDeviceLog: services.createDeviceLog,
                ),
                child: DeviceLogPage(deviceId: id),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Text(state.error?.toString() ?? state.uri.toString()),
      ),
    ),
  );
}

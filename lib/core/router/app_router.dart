import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/calendar/calendar_system_cubit.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/presentation/birthday/bloc/birthday_edit_bloc.dart';
import 'package:nasyad/presentation/birthday/bloc/birthday_list_bloc.dart';
import 'package:nasyad/presentation/birthday/pages/birthday_edit_page.dart';
import 'package:nasyad/presentation/birthday/pages/birthday_list_page.dart';
import 'package:nasyad/presentation/device/bloc/archived_devices_bloc.dart';
import 'package:nasyad/presentation/device/bloc/device_detail_bloc.dart';
import 'package:nasyad/presentation/device/bloc/device_edit_bloc.dart';
import 'package:nasyad/presentation/device/bloc/device_log_bloc.dart';
import 'package:nasyad/presentation/device/bloc/device_list_bloc.dart';
import 'package:nasyad/presentation/device/pages/archived_devices_page.dart';
import 'package:nasyad/presentation/device/pages/device_edit_page.dart';
import 'package:nasyad/presentation/device/pages/device_list_page.dart';
import 'package:nasyad/presentation/device/pages/device_log.dart';
import 'package:nasyad/presentation/device/pages/device_view_page.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';
import 'package:nasyad/presentation/home/pages/home_page.dart';
import 'package:nasyad/presentation/preferences/pages/preferences_page.dart';
import 'package:nasyad/presentation/search/bloc/search_bloc.dart';
import 'package:nasyad/presentation/search/pages/search_page.dart';
import 'package:nasyad/presentation/splash/bloc/splash_cubit.dart';
import 'package:nasyad/presentation/splash/pages/splash_page.dart';
import 'package:nasyad/presentation/transfer/bloc/transfer_bloc.dart';
import 'package:nasyad/presentation/transfer/pages/transfer_page.dart';

abstract final class AppRoutes {
  static const splash = 'splash';
  static const home = 'home';
  static const devices = 'devices';
  static const preferences = 'preferences';
  static const transfer = 'transfer';
  static const birthdays = 'birthdays';
  static const birthdayNew = 'birthday_new';
  static const birthdayEdit = 'birthday_edit';
  static const deviceNew = 'device_new';
  static const deviceView = 'device_view';
  static const deviceEdit = 'device_edit';
  static const deviceLog = 'device_log';
  static const archivedDevices = 'archived_devices';
  static const search = 'search';
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
                HomeBloc(services.watchHomeReminders)..add(const HomeStarted()),
            child: const HomePage(),
          );
        },
        routes: [
          GoRoute(
            path: 'search',
            name: AppRoutes.search,
            builder: (context, state) {
              final services = AppServicesScope.of(context);
              return BlocProvider(
                create: (_) => SearchBloc(search: services.search),
                child: const SearchPage(),
              );
            },
          ),
          GoRoute(
            path: 'devices',
            name: AppRoutes.devices,
            builder: (context, state) {
              final services = AppServicesScope.of(context);
              return BlocProvider(
                create: (_) =>
                    DeviceListBloc(services.watchDeviceSummaries)
                      ..add(const DeviceListStarted()),
                child: const DeviceListPage(),
              );
            },
            routes: [
              GoRoute(
                path: 'archived',
                name: AppRoutes.archivedDevices,
                builder: (context, state) {
                  final services = AppServicesScope.of(context);
                  return BlocProvider(
                    create: (_) => ArchivedDevicesBloc(
                      watchArchivedRootDevices:
                          services.watchArchivedRootDevices,
                      restoreDevice: services.restoreDevice,
                    )..add(const ArchivedDevicesStarted()),
                    child: const ArchivedDevicesPage(),
                  );
                },
              ),
            ],
          ),
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
          GoRoute(
            path: 'birthdays',
            name: AppRoutes.birthdays,
            builder: (context, state) {
              final services = AppServicesScope.of(context);
              return BlocProvider(
                create: (_) => BirthdayListBloc(
                  watchBirthdays: services.watchBirthdays,
                  deleteBirthday: services.deleteBirthday,
                )..add(const BirthdayListStarted()),
                child: const BirthdayListPage(),
              );
            },
            routes: [
              GoRoute(
                path: 'new',
                name: AppRoutes.birthdayNew,
                builder: (context, state) {
                  final services = AppServicesScope.of(context);
                  final preferred = context.read<CalendarSystemCubit>().state;
                  return BlocProvider(
                    create: (_) => BirthdayEditBloc(
                      getBirthday: services.getBirthday,
                      createBirthday: services.createBirthday,
                      updateBirthday: services.updateBirthday,
                      deleteBirthday: services.deleteBirthday,
                      preferredCalendar: preferred,
                    )..add(BirthdayEditStarted(preferredCalendar: preferred)),
                    child: const BirthdayEditPage(),
                  );
                },
              ),
              GoRoute(
                path: ':id/edit',
                name: AppRoutes.birthdayEdit,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final services = AppServicesScope.of(context);
                  final preferred = context.read<CalendarSystemCubit>().state;
                  return BlocProvider(
                    create: (_) => BirthdayEditBloc(
                      birthdayId: id,
                      getBirthday: services.getBirthday,
                      createBirthday: services.createBirthday,
                      updateBirthday: services.updateBirthday,
                      deleteBirthday: services.deleteBirthday,
                      preferredCalendar: preferred,
                    )..add(BirthdayEditStarted(preferredCalendar: preferred)),
                    child: BirthdayEditPage(birthdayId: id),
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
          final parentId = state.uri.queryParameters['parentId'];
          return BlocProvider(
            create: (_) => DeviceEditBloc(
              parentId: parentId,
              getDevice: services.getDevice,
              createDevice: services.createDevice,
              updateDevice: services.updateDevice,
              deleteDevice: services.deleteDevice,
            )..add(const DeviceEditStarted()),
            child: DeviceEditPage(parentId: parentId),
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
              watchDeviceSummary: services.watchDeviceSummary,
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
              final kindParam = state.uri.queryParameters['kind'];
              final initialKind = kindParam == 'usage'
                  ? DeviceLogKind.usageUpdate
                  : DeviceLogKind.maintenanceDone;
              return BlocProvider(
                create: (_) => DeviceLogBloc(
                  deviceId: id,
                  createDeviceLog: services.createDeviceLog,
                  getDevice: services.getDevice,
                  initialKind: initialKind,
                )..add(const DeviceLogStarted()),
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

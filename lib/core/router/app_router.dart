import 'package:go_router/go_router.dart';
import 'package:nasyad/presentation/device/pages/device_edit_page.dart';
import 'package:nasyad/presentation/device/pages/device_log.dart';
import 'package:nasyad/presentation/device/pages/device_view_page.dart';
import 'package:nasyad/presentation/home/pages/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/device/new',
      name: 'device_new',
      builder: (context, state) {
        return DeviceEditPage();
      },
    ),
    GoRoute(
      path: '/device/:id',
      name: 'device_view',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DevicePage(deviceId: id);
      },
    ),
    GoRoute(path: '/device/:id/edit',
    name: 'device_edit',
      builder: (context,state){
      final id = state.pathParameters['id']!;
      return DeviceEditPage(deviceId:id);
      }
    ),GoRoute(path: '/device/:id/log',
    name: 'device_log',
      builder: (context,state){
      final id = state.pathParameters['id']!;
      return DeviceLogPage(deviceId:id);
      }
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_theme.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/presentation/home/widgets/device_reminder_quick_actions.dart';

Widget _wrap(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: '/device/:id/log',
        builder: (context, state) {
          final kind = state.uri.queryParameters['kind'];
          return Scaffold(
            body: Text('log:${state.pathParameters['id']}:$kind'),
          );
        },
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme(),
  );
}

void main() {
  testWidgets('device reminder shows quick actions menu button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ReminderListItem(
          title: 'Pump',
          subtitle: 'Maintenance is due',
          badgeLabel: 'Due',
          icon: Icons.devices_other,
          onQuickActions: () {},
          quickActionsTooltip: 'Quick actions',
        ),
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byTooltip('Quick actions'), findsOneWidget);
  });

  testWidgets('birthday reminder hides quick actions menu button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ReminderListItem(
          title: 'Ali',
          subtitle: 'Birthday is today',
          badgeLabel: 'Due',
          icon: Icons.cake_outlined,
        ),
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('quick actions sheet opens maintenance log route', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: AppButton(
                label: 'Open',
                onPressed: () => showDeviceReminderQuickActions(
                  context: context,
                  deviceId: 'device-1',
                  deviceName: 'Pump',
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Pump'), findsOneWidget);
    expect(find.text('Mark maintained'), findsOneWidget);
    expect(find.text('Update usage'), findsOneWidget);

    await tester.tap(find.text('Mark maintained'));
    await tester.pumpAndSettle();

    expect(find.text('log:device-1:null'), findsOneWidget);
  });

  testWidgets('quick actions sheet opens usage log route', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: AppButton(
                label: 'Open',
                onPressed: () => showDeviceReminderQuickActions(
                  context: context,
                  deviceId: 'device-2',
                  deviceName: 'Car',
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update usage'));
    await tester.pumpAndSettle();

    expect(find.text('log:device-2:usage'), findsOneWidget);
  });
}

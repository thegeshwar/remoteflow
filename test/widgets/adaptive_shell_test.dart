import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/theme/app_theme.dart';
import 'package:remoteflow/widgets/adaptive_shell.dart';

Widget buildTestApp() {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: AdaptiveShell(
      pages: const [
        Center(child: Text('Hosts Page')),
        Center(child: Text('Sessions Page')),
        Center(child: Text('Settings Page')),
      ],
    ),
  );
}

void main() {
  group('AdaptiveShell', () {
    group('compact layout (<600dp)', () {
      testWidgets('shows NavigationBar on narrow screen', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('shows bottom nav at 599dp', (tester) async {
        tester.view.physicalSize =
            Size(AppConstants.compactBreakpoint - 1, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('shows 3 navigation destinations', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(NavigationDestination), findsNWidgets(3));
      });

      testWidgets('shows all nav labels', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.text('Hosts'), findsOneWidget);
        expect(find.text('Sessions'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('starts on Hosts page (index 0)', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.text('Hosts Page'), findsOneWidget);
      });

      testWidgets('tapping Sessions switches to Sessions page',
          (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        await tester.tap(find.text('Sessions'));
        await tester.pumpAndSettle();
        expect(find.text('Sessions Page'), findsOneWidget);
        expect(find.text('Hosts Page'), findsNothing);
      });

      testWidgets('tapping Settings switches to Settings page',
          (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Settings Page'), findsOneWidget);
      });
    });

    group('expanded layout (>=600dp)', () {
      testWidgets('shows NavigationRail on wide screen', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });

      testWidgets('shows nav rail at exactly 600dp', (tester) async {
        tester.view.physicalSize =
            Size(AppConstants.compactBreakpoint, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });

      testWidgets('has VerticalDivider between rail and content',
          (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(VerticalDivider), findsOneWidget);
      });

      testWidgets('shows labels on nav rail', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.text('Hosts'), findsOneWidget);
        expect(find.text('Sessions'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });
    });

    group('safe area', () {
      testWidgets('wraps content in SafeArea (compact)', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(SafeArea), findsAtLeast(1));
      });

      testWidgets('wraps content in SafeArea (expanded)', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestApp());
        expect(find.byType(SafeArea), findsAtLeast(1));
      });
    });

    group('breakpoint constant', () {
      test('compact breakpoint is 600', () {
        expect(AppConstants.compactBreakpoint, 600.0);
      });
    });
  });
}

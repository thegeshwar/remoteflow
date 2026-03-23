import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/theme/app_theme.dart';
import 'package:remoteflow/widgets/responsive_layout.dart';

Widget _buildApp(double width) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SizedBox(
        width: width,
        height: 800,
        child: ResponsiveLayout(
          compact: (_) => const Text('COMPACT'),
          medium: (_) => const Text('MEDIUM'),
          expanded: (_) => const Text('EXPANDED'),
        ),
      ),
    ),
  );
}

void main() {
  group('ResponsiveLayout', () {
    testWidgets('shows compact at 360dp', (tester) async {
      await tester.pumpWidget(_buildApp(360));
      expect(find.text('COMPACT'), findsOneWidget);
    });

    testWidgets('shows compact at 599dp', (tester) async {
      await tester.pumpWidget(_buildApp(599));
      expect(find.text('COMPACT'), findsOneWidget);
    });

    testWidgets('shows medium at 600dp', (tester) async {
      await tester.pumpWidget(_buildApp(600));
      expect(find.text('MEDIUM'), findsOneWidget);
    });

    testWidgets('shows medium at 839dp', (tester) async {
      await tester.pumpWidget(_buildApp(839));
      expect(find.text('MEDIUM'), findsOneWidget);
    });

    testWidgets('shows expanded at 840dp', (tester) async {
      tester.view.physicalSize = const Size(840, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(840));
      expect(find.text('EXPANDED'), findsOneWidget);
    });

    testWidgets('shows expanded at 1024dp', (tester) async {
      tester.view.physicalSize = const Size(1024, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(1024));
      expect(find.text('EXPANDED'), findsOneWidget);
    });
  });

  group('ResponsiveLayout fallbacks', () {
    testWidgets('medium falls back to compact when null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 800,
            child: ResponsiveLayout(
              compact: (_) => const Text('COMPACT'),
            ),
          ),
        ),
      ));
      expect(find.text('COMPACT'), findsOneWidget);
    });

    testWidgets('expanded falls back to medium when null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1024,
            height: 800,
            child: ResponsiveLayout(
              compact: (_) => const Text('COMPACT'),
              medium: (_) => const Text('MEDIUM'),
            ),
          ),
        ),
      ));
      expect(find.text('MEDIUM'), findsOneWidget);
    });
  });

  group('layoutSizeOf', () {
    test('returns compact below 600', () {
      expect(layoutSizeOf(360), LayoutSize.compact);
      expect(layoutSizeOf(599), LayoutSize.compact);
    });

    test('returns medium at 600-839', () {
      expect(layoutSizeOf(600), LayoutSize.medium);
      expect(layoutSizeOf(839), LayoutSize.medium);
    });

    test('returns expanded at 840+', () {
      expect(layoutSizeOf(840), LayoutSize.expanded);
      expect(layoutSizeOf(1024), LayoutSize.expanded);
    });
  });

  group('breakpoint constants', () {
    test('compact breakpoint is 600', () {
      expect(AppConstants.compactBreakpoint, 600.0);
    });

    test('expanded breakpoint is 840', () {
      expect(AppConstants.expandedBreakpoint, 840.0);
    });
  });
}

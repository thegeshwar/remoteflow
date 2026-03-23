import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/theme/app_theme.dart';
import 'package:remoteflow/widgets/new_output_badge.dart';

Widget _buildApp({required bool visible, VoidCallback? onTap}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: Center(
        child: NewOutputBadge(
          visible: visible,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('NewOutputBadge', () {
    testWidgets('shows text when visible', (tester) async {
      await tester.pumpWidget(_buildApp(visible: true));
      expect(find.text('New output below'), findsOneWidget);
    });

    testWidgets('shows down arrow icon when visible', (tester) async {
      await tester.pumpWidget(_buildApp(visible: true));
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('calls onTap when tapped while visible', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildApp(
        visible: true,
        onTap: () => tapped = true,
      ));
      await tester.tap(find.text('New output below'));
      expect(tapped, isTrue);
    });

    testWidgets('does not respond to taps when not visible', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildApp(
        visible: false,
        onTap: () => tapped = true,
      ));
      // IgnorePointer should prevent the tap
      await tester.tap(find.byType(NewOutputBadge), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('uses AnimatedOpacity', (tester) async {
      await tester.pumpWidget(_buildApp(visible: true));
      expect(find.byType(AnimatedOpacity), findsOneWidget);
    });

    testWidgets('opacity is 1.0 when visible', (tester) async {
      await tester.pumpWidget(_buildApp(visible: true));
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('opacity is 0.0 when not visible', (tester) async {
      await tester.pumpWidget(_buildApp(visible: false));
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.0);
    });
  });
}

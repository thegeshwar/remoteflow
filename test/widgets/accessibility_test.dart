import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/theme/app_theme.dart';
import 'package:remoteflow/widgets/accessible_animated_opacity.dart';

void main() {
  group('AccessibleAnimatedOpacity', () {
    testWidgets('uses zero duration when Reduce Motion is on',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: AccessibleAnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300),
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.duration, Duration.zero);
    });

    testWidgets('uses specified duration when Reduce Motion is off',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: false),
            child: Scaffold(
              body: AccessibleAnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300),
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.duration, const Duration(milliseconds: 300));
    });
  });

  group('Accessibility compliance', () {
    test('minimum touch target is 48dp (meets Material and exceeds iOS 44pt)',
        () {
      expect(AppTheme.minTouchTarget, greaterThanOrEqualTo(48.0));
    });

    test('JetBrainsMono font family is set', () {
      expect(AppTheme.fontFamily, 'JetBrainsMono');
    });
  });
}

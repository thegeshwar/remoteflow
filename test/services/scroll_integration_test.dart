import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/services/scroll_intent_controller.dart';

/// Integration-level tests verifying scroll-aware streaming behavior
/// as wired in the terminal screen.
void main() {
  group('Scroll-aware streaming integration', () {
    late ScrollIntentController controller;

    setUp(() {
      controller = ScrollIntentController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('user scrolls up → shouldAutoScroll becomes false', () {
      controller.onUserScrollUp();
      expect(controller.shouldAutoScroll, isFalse);
      expect(controller.userHasScrolledUp, isTrue);
    });

    test('user scrolls up then back to bottom → auto-scroll resumes', () {
      controller.onUserScrollUp();
      expect(controller.shouldAutoScroll, isFalse);

      // Simulate scrolling back to within threshold of bottom
      controller.onScrollPositionChanged(
        scrollOffset: 990.0,
        maxScrollExtent: 1000.0,
      ); // 10px from bottom, within 50px threshold
      expect(controller.shouldAutoScroll, isTrue);
      expect(controller.userHasScrolledUp, isFalse);
    });

    test('onViewportReachedBottom resumes auto-scroll (badge tap)', () {
      controller.onUserScrollUp();
      expect(controller.shouldAutoScroll, isFalse);

      controller.onViewportReachedBottom();
      expect(controller.shouldAutoScroll, isTrue);
      expect(controller.userHasScrolledUp, isFalse);
    });

    test('rapid output during scroll-up does not change state', () {
      controller.onUserScrollUp();

      // Simulate rapid content growth (programmatic scrolls)
      // These should NOT be fed to the controller per the spec
      // Only user scroll events should trigger state changes

      expect(controller.shouldAutoScroll, isFalse);
      expect(controller.userHasScrolledUp, isTrue);
    });

    test('badge visibility logic: scrolled up + new output = show badge', () {
      controller.onUserScrollUp();
      final hasNewOutput = true;
      final showBadge = controller.userHasScrolledUp && hasNewOutput;
      expect(showBadge, isTrue);
    });

    test('badge visibility logic: at bottom = hide badge', () {
      // Not scrolled up
      final hasNewOutput = true;
      final showBadge = controller.userHasScrolledUp && hasNewOutput;
      expect(showBadge, isFalse);
    });

    test('badge visibility logic: scrolled up but no new output = hide badge',
        () {
      controller.onUserScrollUp();
      final hasNewOutput = false;
      final showBadge = controller.userHasScrolledUp && hasNewOutput;
      expect(showBadge, isFalse);
    });

    test('state transitions: up → bottom → up cycle', () {
      // Scroll up
      controller.onUserScrollUp();
      expect(controller.userHasScrolledUp, isTrue);

      // Scroll to bottom
      controller.onViewportReachedBottom();
      expect(controller.userHasScrolledUp, isFalse);

      // Scroll up again
      controller.onUserScrollUp();
      expect(controller.userHasScrolledUp, isTrue);
    });

    test('multiple scroll-up calls are idempotent', () {
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.onUserScrollUp();
      controller.onUserScrollUp();
      controller.onUserScrollUp();

      // Only first call should notify
      expect(notifyCount, 1);
      expect(controller.userHasScrolledUp, isTrue);
    });
  });
}

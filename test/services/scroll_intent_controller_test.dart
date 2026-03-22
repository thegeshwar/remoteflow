import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/services/scroll_intent_controller.dart';

void main() {
  late ScrollIntentController controller;

  setUp(() {
    controller = ScrollIntentController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('ScrollIntentController', () {
    group('initial state', () {
      test('should start with userHasScrolledUp = false', () {
        expect(controller.userHasScrolledUp, isFalse);
      });

      test('should start with shouldAutoScroll = true', () {
        expect(controller.shouldAutoScroll, isTrue);
      });
    });

    group('onUserScrollUp', () {
      test('should set userHasScrolledUp to true', () {
        controller.onUserScrollUp();
        expect(controller.userHasScrolledUp, isTrue);
      });

      test('should set shouldAutoScroll to false', () {
        controller.onUserScrollUp();
        expect(controller.shouldAutoScroll, isFalse);
      });

      test('should notify listeners when state changes', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.onUserScrollUp();
        expect(notified, isTrue);
      });

      test('should not notify listeners when already scrolled up', () {
        controller.onUserScrollUp();

        var notified = false;
        controller.addListener(() => notified = true);

        controller.onUserScrollUp();
        expect(notified, isFalse);
      });
    });

    group('onViewportReachedBottom', () {
      test('should set userHasScrolledUp to false', () {
        controller.onUserScrollUp();
        expect(controller.userHasScrolledUp, isTrue);

        controller.onViewportReachedBottom();
        expect(controller.userHasScrolledUp, isFalse);
      });

      test('should set shouldAutoScroll to true', () {
        controller.onUserScrollUp();
        expect(controller.shouldAutoScroll, isFalse);

        controller.onViewportReachedBottom();
        expect(controller.shouldAutoScroll, isTrue);
      });

      test('should notify listeners when state changes', () {
        controller.onUserScrollUp();

        var notified = false;
        controller.addListener(() => notified = true);

        controller.onViewportReachedBottom();
        expect(notified, isTrue);
      });

      test('should not notify listeners when already at bottom', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.onViewportReachedBottom();
        expect(notified, isFalse);
      });
    });

    group('onScrollPositionChanged', () {
      test('should auto-scroll when within threshold of bottom', () {
        controller.onUserScrollUp();

        controller.onScrollPositionChanged(
          scrollOffset: 950,
          maxScrollExtent: 1000,
        );

        expect(controller.shouldAutoScroll, isTrue);
        expect(controller.userHasScrolledUp, isFalse);
      });

      test('should auto-scroll when exactly at bottom', () {
        controller.onUserScrollUp();

        controller.onScrollPositionChanged(
          scrollOffset: 1000,
          maxScrollExtent: 1000,
        );

        expect(controller.shouldAutoScroll, isTrue);
      });

      test('should suppress auto-scroll when scrolled up beyond threshold', () {
        controller.onScrollPositionChanged(
          scrollOffset: 500,
          maxScrollExtent: 1000,
        );

        expect(controller.shouldAutoScroll, isFalse);
        expect(controller.userHasScrolledUp, isTrue);
      });

      test('should suppress auto-scroll when exactly at threshold boundary', () {
        final threshold = AppConstants.scrollBottomThreshold;

        controller.onScrollPositionChanged(
          scrollOffset: 1000 - threshold - 1,
          maxScrollExtent: 1000,
        );

        expect(controller.shouldAutoScroll, isFalse);
      });

      test('should resume auto-scroll when at threshold boundary', () {
        controller.onUserScrollUp();

        final threshold = AppConstants.scrollBottomThreshold;

        controller.onScrollPositionChanged(
          scrollOffset: 1000 - threshold,
          maxScrollExtent: 1000,
        );

        expect(controller.shouldAutoScroll, isTrue);
      });
    });

    group('rapid state changes', () {
      test('should handle rapid toggle between scroll up and bottom', () {
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.onUserScrollUp();
        expect(controller.userHasScrolledUp, isTrue);
        expect(notifyCount, 1);

        controller.onViewportReachedBottom();
        expect(controller.userHasScrolledUp, isFalse);
        expect(notifyCount, 2);

        controller.onUserScrollUp();
        expect(controller.userHasScrolledUp, isTrue);
        expect(notifyCount, 3);

        controller.onViewportReachedBottom();
        expect(controller.userHasScrolledUp, isFalse);
        expect(notifyCount, 4);
      });

      test('should handle rapid scroll position updates', () {
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Scroll up
        controller.onScrollPositionChanged(scrollOffset: 100, maxScrollExtent: 1000);
        expect(notifyCount, 1);

        // Stay scrolled up — no new notification
        controller.onScrollPositionChanged(scrollOffset: 200, maxScrollExtent: 1000);
        expect(notifyCount, 1);

        // Reach bottom
        controller.onScrollPositionChanged(scrollOffset: 980, maxScrollExtent: 1000);
        expect(notifyCount, 2);

        // Stay at bottom — no new notification
        controller.onScrollPositionChanged(scrollOffset: 1000, maxScrollExtent: 1000);
        expect(notifyCount, 2);
      });

      test('should only notify on actual state transitions', () {
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Multiple scroll-ups should only notify once
        for (var i = 0; i < 100; i++) {
          controller.onUserScrollUp();
        }
        expect(notifyCount, 1);

        // Multiple bottom-reaches should only notify once
        for (var i = 0; i < 100; i++) {
          controller.onViewportReachedBottom();
        }
        expect(notifyCount, 2);
      });
    });

    group('reset', () {
      test('should reset to initial state', () {
        controller.onUserScrollUp();
        expect(controller.userHasScrolledUp, isTrue);

        controller.reset();
        expect(controller.userHasScrolledUp, isFalse);
        expect(controller.shouldAutoScroll, isTrue);
      });

      test('should notify listeners on reset', () {
        controller.onUserScrollUp();

        var notified = false;
        controller.addListener(() => notified = true);

        controller.reset();
        expect(notified, isTrue);
      });

      test('should not notify if already in initial state', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.reset();
        expect(notified, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle zero scroll extent', () {
        controller.onScrollPositionChanged(
          scrollOffset: 0,
          maxScrollExtent: 0,
        );
        expect(controller.shouldAutoScroll, isTrue);
      });

      test('should handle negative distance from bottom gracefully', () {
        // scrollOffset > maxScrollExtent (overscroll)
        controller.onUserScrollUp();
        controller.onScrollPositionChanged(
          scrollOffset: 1050,
          maxScrollExtent: 1000,
        );
        expect(controller.shouldAutoScroll, isTrue);
      });

      test('should work correctly as ChangeNotifier with multiple listeners', () {
        var listener1Count = 0;
        var listener2Count = 0;

        void listener1() => listener1Count++;
        void listener2() => listener2Count++;

        controller.addListener(listener1);
        controller.addListener(listener2);

        controller.onUserScrollUp();
        expect(listener1Count, 1);
        expect(listener2Count, 1);

        controller.removeListener(listener1);

        controller.onViewportReachedBottom();
        expect(listener1Count, 1); // removed, not called
        expect(listener2Count, 2);
      });
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:remoteflow/constants.dart';

/// Controls scroll behavior during live terminal output streaming.
///
/// This is the core differentiator of RemoteFlow. The controller tracks
/// whether the user has intentionally scrolled away from the bottom of
/// the terminal output. When the user scrolls up, auto-scroll is suppressed.
/// When the user scrolls back to the bottom, auto-scroll resumes.
///
/// ## State Machine
/// - `userHasScrolledUp == false` → auto-scroll is active
/// - `userHasScrolledUp == true` → auto-scroll is suppressed
///
/// ## Usage
/// ```dart
/// final controller = ScrollIntentController();
/// controller.addListener(() {
///   if (controller.shouldAutoScroll) {
///     scrollToBottom();
///   }
/// });
/// ```
class ScrollIntentController extends ChangeNotifier {
  bool _userHasScrolledUp = false;

  /// Whether the user has manually scrolled up from the bottom.
  bool get userHasScrolledUp => _userHasScrolledUp;

  /// Whether the terminal should auto-scroll to show new output.
  ///
  /// Returns `true` when the user is at (or near) the bottom of output,
  /// `false` when the user has scrolled up to read earlier output.
  bool get shouldAutoScroll => !_userHasScrolledUp;

  /// Call when the user manually scrolls up away from the bottom.
  ///
  /// This suppresses auto-scroll so the user can read earlier output
  /// without being yanked back to the bottom by new incoming data.
  void onUserScrollUp() {
    if (!_userHasScrolledUp) {
      _userHasScrolledUp = true;
      notifyListeners();
    }
  }

  /// Call when the viewport has reached (or is within threshold of) the bottom.
  ///
  /// This re-enables auto-scroll so new output is followed again.
  void onViewportReachedBottom() {
    if (_userHasScrolledUp) {
      _userHasScrolledUp = false;
      notifyListeners();
    }
  }

  /// Evaluates a scroll position update and determines intent.
  ///
  /// [scrollOffset] is the current scroll position.
  /// [maxScrollExtent] is the maximum scrollable distance.
  ///
  /// If the viewport is within [AppConstants.scrollBottomThreshold] pixels
  /// of the bottom, auto-scroll resumes. Otherwise, if the user has scrolled
  /// up, auto-scroll is suppressed.
  void onScrollPositionChanged({
    required double scrollOffset,
    required double maxScrollExtent,
  }) {
    final distanceFromBottom = maxScrollExtent - scrollOffset;

    if (distanceFromBottom <= AppConstants.scrollBottomThreshold) {
      onViewportReachedBottom();
    } else {
      onUserScrollUp();
    }
  }

  /// Resets the controller to its initial state (auto-scroll active).
  void reset() {
    if (_userHasScrolledUp) {
      _userHasScrolledUp = false;
      notifyListeners();
    }
  }
}

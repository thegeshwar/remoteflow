import 'package:flutter/material.dart';

/// An [AnimatedOpacity] that respects the Reduce Motion accessibility setting.
///
/// When Reduce Motion is enabled, transitions happen instantly (zero duration).
/// Otherwise, uses the specified [duration].
class AccessibleAnimatedOpacity extends StatelessWidget {
  /// Creates an [AccessibleAnimatedOpacity].
  const AccessibleAnimatedOpacity({
    super.key,
    required this.opacity,
    required this.duration,
    required this.child,
  });

  /// Target opacity value.
  final double opacity;

  /// Animation duration (ignored when Reduce Motion is on).
  final Duration duration;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedOpacity(
      opacity: opacity,
      duration: reduceMotion ? Duration.zero : duration,
      child: child,
    );
  }
}

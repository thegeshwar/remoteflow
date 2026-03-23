import 'package:flutter/material.dart';
import 'package:remoteflow/theme/app_theme.dart';

/// A floating badge that appears when new terminal output arrives
/// while the user has scrolled up.
///
/// Tapping the badge scrolls the terminal to the bottom and
/// resumes auto-scroll.
class NewOutputBadge extends StatelessWidget {
  /// Creates a [NewOutputBadge].
  const NewOutputBadge({
    super.key,
    required this.visible,
    required this.onTap,
  });

  /// Whether the badge is visible.
  final bool visible;

  /// Called when the user taps the badge to scroll to bottom.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: Semantics(
          label: 'New output below, tap to scroll to bottom',
          button: true,
          child: GestureDetector(
            onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            constraints: const BoxConstraints(
              minHeight: AppTheme.minTouchTarget,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'New output below',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

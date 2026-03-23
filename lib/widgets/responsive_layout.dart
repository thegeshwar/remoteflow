import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';

/// Layout size class based on screen width breakpoints.
enum LayoutSize {
  /// Width < 600dp — phone portrait, small screens.
  compact,

  /// Width 600-840dp — phone landscape, small tablets.
  medium,

  /// Width > 840dp — tablets, desktops.
  expanded,
}

/// Determines the current [LayoutSize] from screen width.
LayoutSize layoutSizeOf(double width) {
  if (width < AppConstants.compactBreakpoint) return LayoutSize.compact;
  if (width < AppConstants.expandedBreakpoint) return LayoutSize.medium;
  return LayoutSize.expanded;
}

/// A widget that builds different layouts based on screen width.
///
/// Uses [LayoutBuilder] to detect available width and selects
/// the appropriate builder for compact, medium, or expanded layouts.
class ResponsiveLayout extends StatelessWidget {
  /// Creates a [ResponsiveLayout].
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  /// Builder for compact layout (<600dp).
  final WidgetBuilder compact;

  /// Builder for medium layout (600-840dp). Falls back to [compact].
  final WidgetBuilder? medium;

  /// Builder for expanded layout (>840dp). Falls back to [medium] then [compact].
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = layoutSizeOf(constraints.maxWidth);
        switch (size) {
          case LayoutSize.expanded:
            return (expanded ?? medium ?? compact)(context);
          case LayoutSize.medium:
            return (medium ?? compact)(context);
          case LayoutSize.compact:
            return compact(context);
        }
      },
    );
  }
}

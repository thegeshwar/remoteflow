import 'package:flutter/material.dart';

/// A terminal widget that renders SSH output with scroll-aware streaming.
///
/// Wraps xterm.dart's terminal widget and integrates with
/// [ScrollIntentController] to provide intelligent scroll behavior.
class TerminalView extends StatefulWidget {
  /// The session ID this terminal is displaying.
  final String sessionId;

  /// Creates a [TerminalView] for the given [sessionId].
  const TerminalView({
    super.key,
    required this.sessionId,
  });

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement xterm.dart terminal rendering
    return const Center(
      child: Text(
        'Terminal view — not yet implemented',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Screen containing the terminal view for an active SSH session.
///
/// Manages the terminal lifecycle, input forwarding, and
/// scroll-aware streaming behavior.
class TerminalScreen extends StatelessWidget {
  /// The session ID to display.
  final String sessionId;

  /// Creates a [TerminalScreen] for the given [sessionId].
  const TerminalScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement
    return const Scaffold(
      body: Center(child: Text('Terminal')),
    );
  }
}

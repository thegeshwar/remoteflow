import 'package:flutter/material.dart';

/// Widget for managing SSH host connections.
///
/// Displays a list of saved hosts and provides UI for
/// adding, editing, deleting, and connecting to hosts.
class ConnectionManager extends StatefulWidget {
  /// Callback when a host is selected for connection.
  final void Function(String hostId)? onConnect;

  /// Creates a [ConnectionManager] widget.
  const ConnectionManager({
    super.key,
    this.onConnect,
  });

  @override
  State<ConnectionManager> createState() => _ConnectionManagerState();
}

class _ConnectionManagerState extends State<ConnectionManager> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement connection manager UI
    return const Center(
      child: Text(
        'Connection manager — not yet implemented',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

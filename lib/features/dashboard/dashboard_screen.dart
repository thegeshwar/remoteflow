import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/models/session.dart';
import 'package:remoteflow/services/ssh_service.dart';
import 'package:remoteflow/theme/app_theme.dart';

/// Dashboard screen showing active SSH sessions as live preview cards.
///
/// Displays up to [AppConstants.maxSessions] sessions in a responsive
/// grid layout. Each card shows host label, status, and recent output.
/// Tapping a card navigates to the full-screen terminal.
class DashboardScreen extends StatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key, this.sshService});

  /// SSH service providing active connections.
  final SSHService? sshService;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

/// State for [DashboardScreen], exposed for testing.
class DashboardScreenState extends State<DashboardScreen> {
  /// Current active sessions.
  Map<String, Session> get sessions =>
      widget.sshService?.sessions ?? {};

  @override
  Widget build(BuildContext context) {
    final sessionEntries = sessions.entries.toList();

    if (sessionEntries.isEmpty) {
      return _buildEmptyState(context);
    }

    final canCreate = widget.sshService?.canCreateSession ?? true;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sessions (${sessionEntries.length}/${AppConstants.maxSessions})',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: canCreate ? _onNewSession : null,
                icon: const Icon(Icons.add),
                tooltip: canCreate
                    ? 'New session'
                    : 'Session limit reached (${AppConstants.maxSessions})',
                style: IconButton.styleFrom(
                  minimumSize: const Size(
                    AppTheme.minTouchTarget,
                    AppTheme.minTouchTarget,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSessionGrid(context, sessionEntries),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No active sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect to a host to start a session',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionGrid(
    BuildContext context,
    List<MapEntry<String, Session>> entries,
  ) {
    final count = entries.length;

    if (count == 1) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildSessionCard(context, entries[0]),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count <= 2 ? 1 : 2,
        childAspectRatio: count <= 2 ? 2.5 : 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return _buildSessionCard(context, entries[index]);
      },
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    MapEntry<String, Session> entry,
  ) {
    final session = entry.value;
    final colorScheme = Theme.of(context).colorScheme;
    final isConnected = session.state == SessionState.connected;

    return Semantics(
      label: 'Session ${session.hostId}, ${session.state.name}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isConnected ? () => _onSessionTap(entry.key) : null,
          onLongPress: () => _onCloseSession(entry.key),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isConnected ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                      color: isConnected
                          ? colorScheme.secondary
                          : colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.hostId,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session.state.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (session.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.errorMessage!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Spacer(),
                // Mini terminal preview area
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      isConnected ? 'Terminal output...' : 'Disconnected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: AppConstants.defaultTerminalFontFamily,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSessionTap(String sessionId) {
    // TODO: Navigate to terminal screen (already built)
  }

  void _onNewSession() {
    // TODO: Show host picker to create new session
  }

  /// Closes a session after confirmation.
  Future<void> _onCloseSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Session'),
        content: const Text(
          'Disconnect and close this session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.sshService?.disconnect(sessionId);
      if (mounted) setState(() {});
    }
  }
}

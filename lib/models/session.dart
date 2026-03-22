/// Represents the state of an SSH session.
enum SessionState {
  /// Session is being established.
  connecting,

  /// Session is active and connected.
  connected,

  /// Session has been disconnected.
  disconnected,

  /// Session encountered an error.
  error,
}

/// Represents an active or historical SSH session.
///
/// Tracks connection metadata for session management and history.
class Session {
  /// Unique identifier for this session.
  final String id;

  /// ID of the host this session is connected to.
  final String hostId;

  /// Current state of the session.
  SessionState state;

  /// Timestamp when the session was initiated.
  final DateTime startedAt;

  /// Timestamp when the session ended (null if still active).
  DateTime? endedAt;

  /// Error message if the session is in error state.
  String? errorMessage;

  /// Creates a new [Session] instance.
  Session({
    required this.id,
    required this.hostId,
    this.state = SessionState.connecting,
    DateTime? startedAt,
    this.endedAt,
    this.errorMessage,
  }) : startedAt = startedAt ?? DateTime.now();
}

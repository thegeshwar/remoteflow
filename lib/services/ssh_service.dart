import 'dart:async';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/models/session.dart';
import 'package:remoteflow/services/scroll_intent_controller.dart';
import 'package:xterm/xterm.dart';

/// Holds runtime references for an active SSH connection.
///
/// This is NOT persisted — it exists only while the session is active.
/// [Session] is the serializable state model; this holds live objects.
class ActiveConnection {
  /// Creates an [ActiveConnection].
  ActiveConnection({
    required this.session,
    required this.client,
    required this.sshSession,
    required this.terminal,
    required this.scrollController,
  });

  /// The serializable session state.
  final Session session;

  /// The dartssh2 SSH client.
  final SSHClient client;

  /// The SSH shell session.
  final SSHSession sshSession;

  /// The xterm.dart terminal instance for rendering.
  final Terminal terminal;

  /// Scroll intent controller for this session's terminal.
  final ScrollIntentController scrollController;

  /// Subscription to SSH channel stdout.
  StreamSubscription<Uint8List>? stdoutSubscription;

  /// Subscription to SSH channel stderr.
  StreamSubscription<Uint8List>? stderrSubscription;
}

/// Manages SSH connections using dartssh2.
///
/// Holds a map of [ActiveConnection] instances, one per session.
/// Provides methods to connect, disconnect, send input, and resize.
class SSHService {
  /// Active connections indexed by session ID.
  final Map<String, ActiveConnection> _connections = {};

  /// Returns all active sessions (state-only, no runtime refs).
  Map<String, Session> get sessions {
    return Map.fromEntries(
      _connections.entries.map((e) => MapEntry(e.key, e.value.session)),
    );
  }

  /// Returns the number of active connections.
  int get activeCount => _connections.length;

  /// Returns the [ActiveConnection] for a session, or null.
  ActiveConnection? getConnection(String sessionId) => _connections[sessionId];

  /// Whether more sessions can be created.
  bool get canCreateSession => activeCount < AppConstants.maxSessions;

  /// Establishes an SSH connection to the given [host] with [credentials].
  ///
  /// Creates an SSH client, authenticates, opens a shell session,
  /// and wires up a Terminal instance.
  ///
  /// Throws [StateError] if the max session limit is reached.
  /// Throws [SSHAuthFailError] if authentication fails.
  /// Throws [SocketException] if the host is unreachable.
  Future<ActiveConnection> connect(
    Host host,
    HostCredentials credentials,
  ) async {
    if (!canCreateSession) {
      throw StateError(
        'Maximum session limit (${AppConstants.maxSessions}) reached. '
        'Close an existing session before opening a new one.',
      );
    }

    final sessionId =
        '${host.id}_${DateTime.now().millisecondsSinceEpoch}';
    final session = Session(
      id: sessionId,
      hostId: host.id,
      state: SessionState.connecting,
    );

    try {
      final socket = await SSHSocket.connect(
        host.hostname,
        host.port,
        timeout: AppConstants.connectionTimeout,
      );

      final client = SSHClient(
        socket,
        username: host.username,
        onPasswordRequest: host.authMethod == AuthMethod.password
            ? () => credentials.password ?? ''
            : null,
        identities: host.authMethod == AuthMethod.sshKey
            ? _buildKeyPairs(credentials)
            : null,
      );

      await client.authenticated;

      final sshSession = await client.shell(
        pty: SSHPtyConfig(
          type: 'xterm-256color',
        ),
      );

      final terminal = Terminal(
        maxLines: AppConstants.defaultScrollbackLines,
      );
      final scrollController = ScrollIntentController();

      // Wire SSH output to terminal
      final connection = ActiveConnection(
        session: session,
        client: client,
        sshSession: sshSession,
        terminal: terminal,
        scrollController: scrollController,
      );

      connection.stdoutSubscription = sshSession.stdout.listen((data) {
        terminal.write(String.fromCharCodes(data));
      });

      connection.stderrSubscription = sshSession.stderr.listen((data) {
        terminal.write(String.fromCharCodes(data));
      });

      // Wire terminal input to SSH
      terminal.onOutput = (data) {
        sshSession.write(Uint8List.fromList(data.codeUnits));
      };

      session.state = SessionState.connected;
      _connections[sessionId] = connection;
      return connection;
    } catch (e) {
      session.state = SessionState.error;
      session.errorMessage = e.toString();
      session.endedAt = DateTime.now();
      rethrow;
    }
  }

  /// Disconnects the session with the given [sessionId].
  Future<void> disconnect(String sessionId) async {
    final connection = _connections.remove(sessionId);
    if (connection == null) return;

    await connection.stdoutSubscription?.cancel();
    await connection.stderrSubscription?.cancel();
    connection.sshSession.close();
    connection.client.close();
    connection.scrollController.dispose();
    connection.session.state = SessionState.disconnected;
    connection.session.endedAt = DateTime.now();
  }

  /// Sends raw [data] to the remote shell for the given [sessionId].
  ///
  /// Throws [StateError] if the session is not found.
  void sendInput(String sessionId, Uint8List data) {
    final connection = _connections[sessionId];
    if (connection == null) {
      throw StateError('No active session with id: $sessionId');
    }
    connection.sshSession.write(data);
  }

  /// Notifies the remote server of a terminal resize.
  ///
  /// Throws [StateError] if the session is not found.
  void resizeTerminal(String sessionId, int width, int height) {
    final connection = _connections[sessionId];
    if (connection == null) {
      throw StateError('No active session with id: $sessionId');
    }
    connection.sshSession.resizeTerminal(width, height);
  }

  /// Disconnects all active sessions.
  Future<void> disconnectAll() async {
    final ids = _connections.keys.toList();
    for (final id in ids) {
      await disconnect(id);
    }
  }

  /// Disposes of all resources.
  Future<void> dispose() async {
    await disconnectAll();
  }

  /// Builds SSH key pairs from credentials for dartssh2.
  List<SSHKeyPair> _buildKeyPairs(HostCredentials credentials) {
    final keyContent = credentials.privateKeyContent;
    if (keyContent == null || keyContent.isEmpty) return [];

    if (credentials.passphrase != null &&
        credentials.passphrase!.isNotEmpty) {
      return SSHKeyPair.fromPem(keyContent, credentials.passphrase!);
    }
    return SSHKeyPair.fromPem(keyContent);
  }
}

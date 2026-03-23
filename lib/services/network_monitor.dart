import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity state using connectivity_plus.
///
/// Provides a stream of network availability and current status.
class NetworkMonitor {
  /// Creates a [NetworkMonitor].
  NetworkMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _controller = StreamController<bool>.broadcast();

  bool _isConnected = true;

  /// Whether the device currently has network connectivity.
  bool get isConnected => _isConnected;

  /// Stream of connectivity changes (true = connected, false = disconnected).
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Starts monitoring network connectivity.
  Future<void> start() async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  /// Stops monitoring network connectivity.
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }

  void _updateState(List<ConnectivityResult> results) {
    final connected = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
    if (connected != _isConnected) {
      _isConnected = connected;
      _controller.add(_isConnected);
    }
  }

  /// Returns a human-readable error message for common SSH failure modes.
  static String describeError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('connection refused')) {
      return 'Connection refused — check host and port';
    }
    if (message.contains('auth') || message.contains('permission denied')) {
      return 'Authentication failed — check credentials';
    }
    if (message.contains('timeout') || message.contains('timed out')) {
      return 'Connection timed out — host may be unreachable';
    }
    if (message.contains('no route') ||
        message.contains('network is unreachable')) {
      return 'Network unreachable — check your connection';
    }
    if (message.contains('host not found') ||
        message.contains('name or service not known')) {
      return 'Host not found — check hostname';
    }
    return 'Connection error: ${error.toString()}';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/services/network_monitor.dart';

void main() {
  group('NetworkMonitor', () {
    group('describeError', () {
      test('describes connection refused', () {
        final msg =
            NetworkMonitor.describeError(Exception('Connection refused'));
        expect(msg, contains('Connection refused'));
        expect(msg, contains('check host and port'));
      });

      test('describes auth failure', () {
        final msg =
            NetworkMonitor.describeError(Exception('Auth failed'));
        expect(msg, contains('Authentication failed'));
      });

      test('describes timeout', () {
        final msg =
            NetworkMonitor.describeError(Exception('Connection timed out'));
        expect(msg, contains('timed out'));
      });

      test('describes network unreachable', () {
        final msg =
            NetworkMonitor.describeError(Exception('Network is unreachable'));
        expect(msg, contains('Network unreachable'));
      });

      test('describes host not found', () {
        final msg =
            NetworkMonitor.describeError(Exception('Host not found'));
        expect(msg, contains('Host not found'));
      });

      test('describes unknown error', () {
        final msg =
            NetworkMonitor.describeError(Exception('Something weird'));
        expect(msg, contains('Connection error'));
      });
    });

    group('initial state', () {
      test('starts connected', () {
        final monitor = NetworkMonitor();
        expect(monitor.isConnected, isTrue);
        monitor.dispose();
      });
    });
  });
}

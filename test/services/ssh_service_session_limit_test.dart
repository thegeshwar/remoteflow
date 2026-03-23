import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/services/ssh_service.dart';

void main() {
  group('SSHService session limits', () {
    late SSHService service;

    setUp(() {
      service = SSHService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('canCreateSession is true when no sessions', () {
      expect(service.canCreateSession, isTrue);
    });

    test('max sessions constant is 4', () {
      expect(AppConstants.maxSessions, 4);
    });

    test('activeCount starts at 0', () {
      expect(service.activeCount, 0);
    });

    test('sessions map starts empty', () {
      expect(service.sessions, isEmpty);
    });
  });
}

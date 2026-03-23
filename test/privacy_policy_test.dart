import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';

void main() {
  group('Privacy policy', () {
    test('HTML file exists', () {
      final file = File('docs/privacy-policy.html');
      expect(file.existsSync(), isTrue);
    });

    test('HTML contains required sections', () {
      final content = File('docs/privacy-policy.html').readAsStringSync();
      expect(content, contains('Privacy Policy'));
      expect(content, contains('Data Storage'));
      expect(content, contains('locally on your device'));
      expect(content, contains('Keychain'));
      expect(content, contains('Keystore'));
      expect(content, contains('not send analytics'));
      expect(content, contains('share any data with third parties'));
      expect(content, contains('SSH Encryption'));
      expect(content, contains('Data Deletion'));
    });

    test('privacy policy URL is configured', () {
      expect(AppConstants.privacyPolicyUrl, isNotEmpty);
      expect(AppConstants.privacyPolicyUrl, contains('privacy-policy'));
    });
  });
}

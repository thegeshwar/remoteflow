import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';

void main() {
  group('Build validation', () {
    group('Android config', () {
      late String buildGradle;
      late String manifest;

      setUpAll(() {
        buildGradle = File('android/app/build.gradle.kts').readAsStringSync();
        manifest = File('android/app/src/main/AndroidManifest.xml')
            .readAsStringSync();
      });

      test('targets SDK 35', () {
        expect(buildGradle, contains('targetSdk = 35'));
      });

      test('min SDK is 23', () {
        expect(buildGradle, contains('minSdk = 23'));
      });

      test('R8 minification enabled', () {
        expect(buildGradle, contains('isMinifyEnabled = true'));
      });

      test('only declares required permissions', () {
        expect(manifest, contains('android.permission.INTERNET'));
        expect(manifest, contains('android.permission.ACCESS_NETWORK_STATE'));
        expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('android.permission.CAMERA')));
        expect(manifest, isNot(contains('READ_CONTACTS')));
        expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
      });

      test('network security config referenced', () {
        expect(manifest, contains('networkSecurityConfig'));
      });

      test('cleartext traffic blocked', () {
        final nsc = File(
                'android/app/src/main/res/xml/network_security_config.xml')
            .readAsStringSync();
        expect(nsc, contains('cleartextTrafficPermitted="false"'));
      });
    });

    group('project files', () {
      test('BUILDING.md exists', () {
        expect(File('BUILDING.md').existsSync(), isTrue);
      });

      test('privacy policy exists', () {
        expect(File('docs/privacy-policy.html').existsSync(), isTrue);
      });

      test('proguard rules exist', () {
        expect(File('android/app/proguard-rules.pro').existsSync(), isTrue);
      });
    });

    group('constants', () {
      test('app name is RemoteFlow', () {
        expect(AppConstants.appName, 'RemoteFlow');
      });

      test('privacy policy URL is set', () {
        expect(AppConstants.privacyPolicyUrl, isNotEmpty);
      });

      test('max sessions is 4', () {
        expect(AppConstants.maxSessions, 4);
      });
    });
  });
}

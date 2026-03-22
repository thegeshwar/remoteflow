import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/constants.dart';

/// Tests verifying Android build configuration matches Play Store requirements.
void main() {
  group('Android build constants', () {
    test('targetSdk is 35', () {
      expect(AppConstants.androidTargetSdk, 35);
    });

    test('minSdk is 23', () {
      expect(AppConstants.androidMinSdk, 23);
    });

    test('compileSdk is 35', () {
      expect(AppConstants.androidCompileSdk, 35);
    });
  });

  group('Android build.gradle.kts', () {
    late String buildGradle;

    setUpAll(() {
      buildGradle = File('android/app/build.gradle.kts').readAsStringSync();
    });

    test('compileSdk is set to 35', () {
      expect(buildGradle, contains('compileSdk = 35'));
    });

    test('minSdk is set to 23', () {
      expect(buildGradle, contains('minSdk = 23'));
    });

    test('targetSdk is set to 35', () {
      expect(buildGradle, contains('targetSdk = 35'));
    });

    test('R8 minification is enabled for release', () {
      expect(buildGradle, contains('isMinifyEnabled = true'));
    });

    test('resource shrinking is enabled for release', () {
      expect(buildGradle, contains('isShrinkResources = true'));
    });
  });

  group('AndroidManifest.xml', () {
    late String manifest;

    setUpAll(() {
      manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    });

    test('declares INTERNET permission', () {
      expect(manifest, contains('android.permission.INTERNET'));
    });

    test('declares ACCESS_NETWORK_STATE permission', () {
      expect(manifest, contains('android.permission.ACCESS_NETWORK_STATE'));
    });

    test('does not declare WRITE_EXTERNAL_STORAGE', () {
      expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    });

    test('does not declare READ_EXTERNAL_STORAGE', () {
      expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
    });

    test('does not declare CAMERA', () {
      expect(manifest, isNot(contains('android.permission.CAMERA')));
    });

    test('references network security config', () {
      expect(manifest, contains('android:networkSecurityConfig'));
    });
  });

  group('Network security config', () {
    late String networkConfig;

    setUpAll(() {
      networkConfig = File(
              'android/app/src/main/res/xml/network_security_config.xml')
          .readAsStringSync();
    });

    test('blocks cleartext traffic', () {
      expect(networkConfig, contains('cleartextTrafficPermitted="false"'));
    });
  });
}

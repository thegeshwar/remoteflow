# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# dartssh2 uses BouncyCastle-equivalent Dart crypto — no native JNI to keep
# Keep flutter_secure_storage Android implementation
-keep class com.it_nomads.fluttersecurestorage.** { *; }

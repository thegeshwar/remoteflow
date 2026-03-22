import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/features/connection/connection_screen.dart';
import 'package:remoteflow/theme/app_theme.dart';

void main() {
  runApp(const RemoteFlowApp());
}

/// The root widget of RemoteFlow.
class RemoteFlowApp extends StatelessWidget {
  /// Creates the [RemoteFlowApp].
  const RemoteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const ConnectionScreen(),
    );
  }
}

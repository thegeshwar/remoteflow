import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/features/connection/connection_screen.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.surfaceColor,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.accentColor,
          surface: AppConstants.surfaceColor,
          error: AppConstants.errorColor,
        ),
        fontFamily: 'monospace',
      ),
      home: const ConnectionScreen(),
    );
  }
}

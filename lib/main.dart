import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/features/connection/connection_screen.dart';
import 'package:remoteflow/features/dashboard/dashboard_screen.dart';
import 'package:remoteflow/theme/app_theme.dart';
import 'package:remoteflow/widgets/adaptive_shell.dart';

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
      home: AdaptiveShell(
        pages: [
          const ConnectionScreen(),
          const DashboardScreen(),
          const _PlaceholderPage(title: 'Settings'),
        ],
      ),
    );
  }
}

/// Temporary placeholder page until feature screens are built.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/services/scroll_intent_controller.dart';
import 'package:remoteflow/services/ssh_service.dart';
import 'package:remoteflow/theme/app_theme.dart';
import 'package:remoteflow/theme/terminal_themes.dart';
import 'package:remoteflow/widgets/new_output_badge.dart';
import 'package:xterm/xterm.dart' hide TerminalThemes;

/// Full-screen terminal view for an active SSH session.
///
/// Renders SSH output using xterm.dart [TerminalView], applies terminal
/// themes independent of system theme, handles PTY resize, and integrates
/// [ScrollIntentController] for scroll-aware streaming.
class TerminalScreen extends StatefulWidget {
  /// Creates a [TerminalScreen] for the given [sessionId].
  const TerminalScreen({
    super.key,
    required this.sessionId,
    this.sshService,
    this.terminalThemeName,
  });

  /// The session ID to display.
  final String sessionId;

  /// SSH service holding the active connection. If null, shows error state.
  final SSHService? sshService;

  /// Terminal theme name to apply. Defaults to [AppConstants.defaultTerminalTheme].
  final String? terminalThemeName;

  @override
  State<TerminalScreen> createState() => TerminalScreenState();
}

/// State for [TerminalScreen], exposed for testing.
class TerminalScreenState extends State<TerminalScreen> {
  ActiveConnection? _connection;
  bool _isDisconnected = false;
  bool _hasNewOutput = false;

  /// Whether the session has been disconnected.
  bool get isDisconnected => _isDisconnected;

  /// Whether new output has arrived while scrolled up.
  bool get hasNewOutput => _hasNewOutput;

  ScrollIntentController? get _scrollController => _connection?.scrollController;

  AppTerminalTheme get _appTheme {
    return TerminalThemes.byName(
      widget.terminalThemeName ?? AppConstants.defaultTerminalTheme,
    );
  }

  @override
  void initState() {
    super.initState();
    _connection = widget.sshService?.getConnection(widget.sessionId);
    _scrollController?.addListener(_onScrollStateChanged);

    // Listen for new output to show badge when scrolled up
    _connection?.terminal.onOutput = (data) {
      // Forward to SSH (already wired in SSHService)
      // Check if we need to show the new output badge
      if (_scrollController != null &&
          _scrollController!.userHasScrolledUp &&
          !_hasNewOutput) {
        if (mounted) {
          setState(() => _hasNewOutput = true);
        }
      }
    };
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScrollStateChanged);
    super.dispose();
  }

  void _onScrollStateChanged() {
    if (mounted) {
      setState(() {
        // Reset new output badge when auto-scroll resumes
        if (_scrollController?.shouldAutoScroll == true) {
          _hasNewOutput = false;
        }
      });
    }
  }

  /// Called when user taps the "New output below" badge.
  void onBadgeTap() {
    _scrollController?.onViewportReachedBottom();
    setState(() => _hasNewOutput = false);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_scrollController == null) return false;

    // Only feed USER-initiated scrolls to the controller
    if (notification is UserScrollNotification) {
      // User finished a scroll gesture — check position
      if (notification.metrics.hasContentDimensions) {
        _scrollController!.onScrollPositionChanged(
          scrollOffset: notification.metrics.pixels,
          maxScrollExtent: notification.metrics.maxScrollExtent,
        );
      }
    }

    // Also check on scroll end to catch fling-to-bottom
    if (notification is ScrollEndNotification) {
      if (notification.metrics.hasContentDimensions) {
        _scrollController!.onScrollPositionChanged(
          scrollOffset: notification.metrics.pixels,
          maxScrollExtent: notification.metrics.maxScrollExtent,
        );
      }
    }

    return false;
  }

  Future<void> _onDisconnect() async {
    await widget.sshService?.disconnect(widget.sessionId);
    if (mounted) {
      setState(() => _isDisconnected = true);
    }
  }

  void _onBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_connection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Terminal')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Session not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _onBack,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    AppTheme.minTouchTarget,
                    AppTheme.minTouchTarget,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final terminal = _connection!.terminal;
    final appTheme = _appTheme;
    final showBadge = _scrollController?.userHasScrolledUp == true &&
        _hasNewOutput &&
        !_isDisconnected;

    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        title: Text(
          'Terminal',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: appTheme.background,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            onPressed: _isDisconnected ? null : _onDisconnect,
            icon: const Icon(Icons.power_settings_new),
            tooltip: 'Disconnect',
            style: IconButton.styleFrom(
              minimumSize: const Size(
                AppTheme.minTouchTarget,
                AppTheme.minTouchTarget,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Terminal view with scroll notification listener
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: Semantics(
              label: 'SSH terminal output',
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  invertColors: false,
                ),
                child: TerminalView(
                  terminal,
                  theme: appTheme.toXtermTheme(),
                  textStyle: TerminalStyle(
                    fontFamily: AppConstants.defaultTerminalFontFamily,
                    fontSize: AppConstants.defaultFontSize,
                  ),
                  autofocus: true,
                ),
              ),
            ),
          ),
          // "New output below" badge
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: NewOutputBadge(
                visible: showBadge,
                onTap: onBadgeTap,
              ),
            ),
          ),
          // Disconnect overlay
          if (_isDisconnected)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link_off,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Disconnected',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _onBack,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(
                                AppTheme.minTouchTarget,
                                AppTheme.minTouchTarget,
                              ),
                            ),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

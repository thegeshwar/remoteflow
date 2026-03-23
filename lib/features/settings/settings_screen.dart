import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/theme/terminal_themes.dart';

/// Minimum terminal font size.
const double _minFontSize = 10.0;

/// Maximum terminal font size.
const double _maxFontSize = 24.0;

/// Settings screen for app and terminal configuration.
///
/// Provides controls for terminal font size, terminal theme, app theme,
/// biometric lock, and app information.
class SettingsScreen extends StatefulWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key, this.onThemeModeChanged});

  /// Callback when the app theme mode changes.
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

/// State for [SettingsScreen], exposed for testing.
class SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = AppConstants.defaultFontSize;
  String _terminalTheme = AppConstants.defaultTerminalTheme;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _biometricLock = false;

  /// Current font size setting.
  double get fontSize => _fontSize;

  /// Current terminal theme name.
  String get terminalTheme => _terminalTheme;

  /// Current app theme mode.
  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),

        // Terminal section
        Text(
          'Terminal',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),

        // Font size slider
        Semantics(
          label: 'Terminal font size: ${_fontSize.round()} points',
          child: ListTile(
            title: const Text('Font Size'),
            subtitle: Text('${_fontSize.round()} pt'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _fontSize,
                min: _minFontSize,
                max: _maxFontSize,
                divisions: (_maxFontSize - _minFontSize).round(),
                label: '${_fontSize.round()}',
                onChanged: (value) {
                  setState(() => _fontSize = value);
                },
              ),
            ),
          ),
        ),

        // Terminal theme picker
        Semantics(
          label: 'Terminal color theme: $_terminalTheme',
          child: ListTile(
            title: const Text('Terminal Theme'),
            subtitle: Text(_terminalTheme),
            trailing: DropdownButton<String>(
              value: _terminalTheme,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _terminalTheme = value);
                }
              },
              items: TerminalThemes.all.map((theme) {
                return DropdownMenuItem(
                  value: theme.name,
                  child: Text(theme.name),
                );
              }).toList(),
            ),
          ),
        ),

        const Divider(height: 32),

        // Appearance section
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),

        // App theme
        Semantics(
          label: 'App theme: ${_themeMode.name}',
          child: ListTile(
            title: const Text('App Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_brightness),
                ),
              ],
              selected: {_themeMode},
              onSelectionChanged: (selected) {
                setState(() => _themeMode = selected.first);
                widget.onThemeModeChanged?.call(_themeMode);
              },
            ),
          ),
        ),

        const Divider(height: 32),

        // Security section
        Text(
          'Security',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          title: const Text('Biometric Lock'),
          subtitle: const Text(
            'Require biometric auth to view saved credentials',
          ),
          value: _biometricLock,
          onChanged: (value) {
            setState(() => _biometricLock = value);
          },
        ),

        const Divider(height: 32),

        // About section
        Text(
          'About',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),

        ListTile(
          title: const Text('Version'),
          subtitle: const Text(AppConstants.appVersion),
        ),

        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () {
            // TODO: Open privacy policy URL
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minVerticalPadding: 12,
        ),
      ],
    );
  }
}

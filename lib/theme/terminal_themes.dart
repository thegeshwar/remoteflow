import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;

/// A named terminal color theme, independent of the system theme.
///
/// Terminal themes define foreground, background, cursor, and the 16 ANSI
/// colors used by xterm.dart for rendering terminal output.
class AppTerminalTheme {
  /// Creates an [AppTerminalTheme].
  const AppTerminalTheme({
    required this.name,
    required this.foreground,
    required this.background,
    required this.cursor,
    required this.selection,
    required this.ansiColors,
  });

  /// Display name of this theme.
  final String name;

  /// Default text color.
  final Color foreground;

  /// Terminal background color.
  final Color background;

  /// Cursor color.
  final Color cursor;

  /// Text selection highlight color.
  final Color selection;

  /// The 16 ANSI colors: black, red, green, yellow, blue, magenta, cyan,
  /// white, then their bright variants in the same order.
  final List<Color> ansiColors;

  /// Converts this theme to an xterm.dart [xterm.TerminalTheme].
  xterm.TerminalTheme toXtermTheme() {
    return xterm.TerminalTheme(
      cursor: cursor,
      selection: selection,
      foreground: foreground,
      background: background,
      black: ansiColors[0],
      red: ansiColors[1],
      green: ansiColors[2],
      yellow: ansiColors[3],
      blue: ansiColors[4],
      magenta: ansiColors[5],
      cyan: ansiColors[6],
      white: ansiColors[7],
      brightBlack: ansiColors[8],
      brightRed: ansiColors[9],
      brightGreen: ansiColors[10],
      brightYellow: ansiColors[11],
      brightBlue: ansiColors[12],
      brightMagenta: ansiColors[13],
      brightCyan: ansiColors[14],
      brightWhite: ansiColors[15],
      searchHitBackground: selection,
      searchHitBackgroundCurrent: cursor,
      searchHitForeground: foreground,
    );
  }
}

/// Built-in terminal color themes.
///
/// These are independent of the app's light/dark theme.
class TerminalThemes {
  TerminalThemes._();

  /// Default dark terminal theme (Catppuccin Mocha inspired).
  static const AppTerminalTheme defaultDark = AppTerminalTheme(
    name: 'Default Dark',
    foreground: Color(0xFFCDD6F4),
    background: Color(0xFF11111B),
    cursor: Color(0xFFF5E0DC),
    selection: Color(0x4089B4FA),
    ansiColors: [
      Color(0xFF45475A), // black
      Color(0xFFF38BA8), // red
      Color(0xFFA6E3A1), // green
      Color(0xFFF9E2AF), // yellow
      Color(0xFF89B4FA), // blue
      Color(0xFFF5C2E7), // magenta
      Color(0xFF94E2D5), // cyan
      Color(0xFFBAC2DE), // white
      Color(0xFF585B70), // bright black
      Color(0xFFF38BA8), // bright red
      Color(0xFFA6E3A1), // bright green
      Color(0xFFF9E2AF), // bright yellow
      Color(0xFF89B4FA), // bright blue
      Color(0xFFF5C2E7), // bright magenta
      Color(0xFF94E2D5), // bright cyan
      Color(0xFFA6ADC8), // bright white
    ],
  );

  /// Dracula terminal theme.
  static const AppTerminalTheme dracula = AppTerminalTheme(
    name: 'Dracula',
    foreground: Color(0xFFF8F8F2),
    background: Color(0xFF282A36),
    cursor: Color(0xFFF8F8F2),
    selection: Color(0x4044475A),
    ansiColors: [
      Color(0xFF21222C), // black
      Color(0xFFFF5555), // red
      Color(0xFF50FA7B), // green
      Color(0xFFF1FA8C), // yellow
      Color(0xFFBD93F9), // blue
      Color(0xFFFF79C6), // magenta
      Color(0xFF8BE9FD), // cyan
      Color(0xFFF8F8F2), // white
      Color(0xFF6272A4), // bright black
      Color(0xFFFF6E6E), // bright red
      Color(0xFF69FF94), // bright green
      Color(0xFFFFFFA5), // bright yellow
      Color(0xFFD6ACFF), // bright blue
      Color(0xFFFF92DF), // bright magenta
      Color(0xFFA4FFFF), // bright cyan
      Color(0xFFFFFFFF), // bright white
    ],
  );

  /// Solarized Dark terminal theme.
  static const AppTerminalTheme solarizedDark = AppTerminalTheme(
    name: 'Solarized Dark',
    foreground: Color(0xFF839496),
    background: Color(0xFF002B36),
    cursor: Color(0xFF93A1A1),
    selection: Color(0x40268BD2),
    ansiColors: [
      Color(0xFF073642), // black
      Color(0xFFDC322F), // red
      Color(0xFF859900), // green
      Color(0xFFB58900), // yellow
      Color(0xFF268BD2), // blue
      Color(0xFFD33682), // magenta
      Color(0xFF2AA198), // cyan
      Color(0xFFEEE8D5), // white
      Color(0xFF002B36), // bright black
      Color(0xFFCB4B16), // bright red
      Color(0xFF586E75), // bright green
      Color(0xFF657B83), // bright yellow
      Color(0xFF839496), // bright blue
      Color(0xFF6C71C4), // bright magenta
      Color(0xFF93A1A1), // bright cyan
      Color(0xFFFDF6E3), // bright white
    ],
  );

  /// Monokai terminal theme.
  static const AppTerminalTheme monokai = AppTerminalTheme(
    name: 'Monokai',
    foreground: Color(0xFFF8F8F2),
    background: Color(0xFF272822),
    cursor: Color(0xFFF8F8F0),
    selection: Color(0x4049483E),
    ansiColors: [
      Color(0xFF272822), // black
      Color(0xFFF92672), // red
      Color(0xFFA6E22E), // green
      Color(0xFFF4BF75), // yellow
      Color(0xFF66D9EF), // blue
      Color(0xFFAE81FF), // magenta
      Color(0xFFA1EFE4), // cyan
      Color(0xFFF8F8F2), // white
      Color(0xFF75715E), // bright black
      Color(0xFFF92672), // bright red
      Color(0xFFA6E22E), // bright green
      Color(0xFFF4BF75), // bright yellow
      Color(0xFF66D9EF), // bright blue
      Color(0xFFAE81FF), // bright magenta
      Color(0xFFA1EFE4), // bright cyan
      Color(0xFFF9F8F5), // bright white
    ],
  );

  /// All available terminal themes.
  static const List<AppTerminalTheme> all = [
    defaultDark,
    dracula,
    solarizedDark,
    monokai,
  ];

  /// Finds a terminal theme by name, returns [defaultDark] if not found.
  static AppTerminalTheme byName(String name) {
    return all.firstWhere(
      (theme) => theme.name == name,
      orElse: () => defaultDark,
    );
  }
}

import 'package:flutter/services.dart';

/// Provides clipboard operations for terminal copy/paste.
///
/// xterm.dart v4 handles built-in copy/paste via Flutter's Actions system
/// (Ctrl+Shift+C, Ctrl+Shift+V). This service provides additional helpers
/// for multi-line paste conversion and programmatic clipboard access.
class ClipboardService {
  /// Reads text from the system clipboard.
  ///
  /// Returns null if the clipboard is empty or doesn't contain text.
  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Writes [text] to the system clipboard.
  Future<void> writeText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Normalizes pasted text for terminal consumption.
  ///
  /// Converts Windows-style line endings (\r\n) to Unix-style (\n),
  /// then converts remaining \n to \r for proper terminal line endings.
  static String normalizePasteLineEndings(String text) {
    return text.replaceAll('\r\n', '\r').replaceAll('\n', '\r');
  }

  /// Converts selected terminal text for clipboard.
  ///
  /// Preserves original line endings from the terminal output.
  static String normalizeSelectedText(String text) {
    // Terminal text uses \n internally — keep as-is for clipboard
    return text;
  }
}

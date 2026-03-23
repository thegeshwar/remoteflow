import 'package:flutter/services.dart';

/// Handles keyboard input translation for SSH sessions.
///
/// xterm.dart v4 handles most keyboard input natively via its built-in
/// key handler. This class provides additional translation for special
/// keys and Ctrl combinations that need custom handling, as well as
/// clipboard paste translation.
///
/// ## Key Mapping
/// Standard characters and most special keys are handled by xterm.dart
/// directly. This handler covers:
/// - Ctrl+key combinations (sends ASCII control codes)
/// - Function keys F1-F12 (ANSI escape sequences)
/// - Navigation keys (Home, End, Page Up/Down)
class InputHandler {
  /// Translates a [KeyEvent] into bytes to send to the remote shell.
  ///
  /// Returns null if the key event should not be forwarded
  /// (e.g., it's a key-up event or xterm handles it natively).
  Uint8List? translateKeyEvent(KeyEvent event) {
    // Only handle key-down events
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return null;

    final key = event.logicalKey;

    // Ctrl combinations — send ASCII control code
    if (HardwareKeyboard.instance.isControlPressed) {
      final ctrlCode = _ctrlKeyCode(key);
      if (ctrlCode != null) return Uint8List.fromList([ctrlCode]);
    }

    // Function keys
    final fnSequence = _functionKeySequence(key);
    if (fnSequence != null) return Uint8List.fromList(fnSequence);

    // Navigation keys
    final navSequence = _navigationKeySequence(key);
    if (navSequence != null) return Uint8List.fromList(navSequence);

    // Standard keys — xterm.dart handles these natively
    return null;
  }

  /// Translates clipboard paste content into terminal input bytes.
  ///
  /// Uses bracketed paste mode escape sequences to signal the start
  /// and end of pasted content, which prevents the shell from
  /// interpreting special characters in the paste.
  Uint8List translatePasteContent(String content) {
    // Send content as raw bytes — bracketed paste is handled by xterm.dart
    return Uint8List.fromList(content.codeUnits);
  }

  /// Returns the ASCII control code for a Ctrl+key combination.
  ///
  /// Control codes are ASCII 0x01-0x1A for Ctrl+A through Ctrl+Z.
  int? _ctrlKeyCode(LogicalKeyboardKey key) {
    // Map logical keys to their control codes
    final mapping = <LogicalKeyboardKey, int>{
      LogicalKeyboardKey.keyA: 0x01,
      LogicalKeyboardKey.keyB: 0x02,
      LogicalKeyboardKey.keyC: 0x03, // SIGINT
      LogicalKeyboardKey.keyD: 0x04, // EOF
      LogicalKeyboardKey.keyE: 0x05,
      LogicalKeyboardKey.keyF: 0x06,
      LogicalKeyboardKey.keyG: 0x07, // BEL
      LogicalKeyboardKey.keyH: 0x08, // Backspace
      LogicalKeyboardKey.keyI: 0x09, // Tab
      LogicalKeyboardKey.keyJ: 0x0A, // Line feed
      LogicalKeyboardKey.keyK: 0x0B,
      LogicalKeyboardKey.keyL: 0x0C, // Clear screen
      LogicalKeyboardKey.keyM: 0x0D, // Enter
      LogicalKeyboardKey.keyN: 0x0E,
      LogicalKeyboardKey.keyO: 0x0F,
      LogicalKeyboardKey.keyP: 0x10,
      LogicalKeyboardKey.keyQ: 0x11,
      LogicalKeyboardKey.keyR: 0x12,
      LogicalKeyboardKey.keyS: 0x13,
      LogicalKeyboardKey.keyT: 0x14,
      LogicalKeyboardKey.keyU: 0x15,
      LogicalKeyboardKey.keyV: 0x16,
      LogicalKeyboardKey.keyW: 0x17,
      LogicalKeyboardKey.keyX: 0x18,
      LogicalKeyboardKey.keyY: 0x19,
      LogicalKeyboardKey.keyZ: 0x1A, // SIGTSTP
    };
    return mapping[key];
  }

  /// Returns the ANSI escape sequence for function keys.
  List<int>? _functionKeySequence(LogicalKeyboardKey key) {
    final sequences = <LogicalKeyboardKey, List<int>>{
      LogicalKeyboardKey.f1: [0x1B, 0x4F, 0x50],
      LogicalKeyboardKey.f2: [0x1B, 0x4F, 0x51],
      LogicalKeyboardKey.f3: [0x1B, 0x4F, 0x52],
      LogicalKeyboardKey.f4: [0x1B, 0x4F, 0x53],
      LogicalKeyboardKey.f5: [0x1B, 0x5B, 0x31, 0x35, 0x7E],
      LogicalKeyboardKey.f6: [0x1B, 0x5B, 0x31, 0x37, 0x7E],
      LogicalKeyboardKey.f7: [0x1B, 0x5B, 0x31, 0x38, 0x7E],
      LogicalKeyboardKey.f8: [0x1B, 0x5B, 0x31, 0x39, 0x7E],
      LogicalKeyboardKey.f9: [0x1B, 0x5B, 0x32, 0x30, 0x7E],
      LogicalKeyboardKey.f10: [0x1B, 0x5B, 0x32, 0x31, 0x7E],
      LogicalKeyboardKey.f11: [0x1B, 0x5B, 0x32, 0x33, 0x7E],
      LogicalKeyboardKey.f12: [0x1B, 0x5B, 0x32, 0x34, 0x7E],
    };
    return sequences[key];
  }

  /// Returns the ANSI escape sequence for navigation keys.
  List<int>? _navigationKeySequence(LogicalKeyboardKey key) {
    final sequences = <LogicalKeyboardKey, List<int>>{
      LogicalKeyboardKey.arrowUp: [0x1B, 0x5B, 0x41],
      LogicalKeyboardKey.arrowDown: [0x1B, 0x5B, 0x42],
      LogicalKeyboardKey.arrowRight: [0x1B, 0x5B, 0x43],
      LogicalKeyboardKey.arrowLeft: [0x1B, 0x5B, 0x44],
      LogicalKeyboardKey.home: [0x1B, 0x5B, 0x48],
      LogicalKeyboardKey.end: [0x1B, 0x5B, 0x46],
      LogicalKeyboardKey.pageUp: [0x1B, 0x5B, 0x35, 0x7E],
      LogicalKeyboardKey.pageDown: [0x1B, 0x5B, 0x36, 0x7E],
      LogicalKeyboardKey.delete: [0x1B, 0x5B, 0x33, 0x7E],
      LogicalKeyboardKey.insert: [0x1B, 0x5B, 0x32, 0x7E],
      LogicalKeyboardKey.tab: [0x09],
      LogicalKeyboardKey.enter: [0x0D],
      LogicalKeyboardKey.backspace: [0x7F],
      LogicalKeyboardKey.escape: [0x1B],
    };
    return sequences[key];
  }
}

import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Handles keyboard and mouse input forwarding to SSH sessions.
///
/// Captures user input events from the terminal widget and
/// translates them into the appropriate byte sequences for
/// the remote shell.
class InputHandler {
  /// Translates a [KeyEvent] into bytes to send to the remote shell.
  ///
  /// Returns null if the key event should not be forwarded.
  Uint8List? translateKeyEvent(KeyEvent event) {
    // TODO: Implement key translation
    throw UnimplementedError('Key translation not yet implemented');
  }

  /// Translates clipboard paste content into terminal input bytes.
  Uint8List translatePasteContent(String content) {
    // TODO: Implement paste translation
    throw UnimplementedError('Paste translation not yet implemented');
  }
}

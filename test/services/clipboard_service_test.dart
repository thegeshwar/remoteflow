import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/services/clipboard_service.dart';

void main() {
  group('ClipboardService', () {
    group('normalizePasteLineEndings', () {
      test('converts \\r\\n to \\r', () {
        final result =
            ClipboardService.normalizePasteLineEndings('line1\r\nline2');
        expect(result, 'line1\rline2');
      });

      test('converts \\n to \\r', () {
        final result =
            ClipboardService.normalizePasteLineEndings('line1\nline2');
        expect(result, 'line1\rline2');
      });

      test('handles mixed line endings', () {
        final result = ClipboardService.normalizePasteLineEndings(
            'line1\r\nline2\nline3');
        expect(result, 'line1\rline2\rline3');
      });

      test('handles text with no line endings', () {
        final result =
            ClipboardService.normalizePasteLineEndings('no newlines');
        expect(result, 'no newlines');
      });

      test('handles empty string', () {
        final result = ClipboardService.normalizePasteLineEndings('');
        expect(result, '');
      });

      test('handles multiple consecutive newlines', () {
        final result =
            ClipboardService.normalizePasteLineEndings('a\n\n\nb');
        expect(result, 'a\r\r\rb');
      });

      test('preserves existing \\r without duplication', () {
        final result =
            ClipboardService.normalizePasteLineEndings('line1\rline2');
        expect(result, 'line1\rline2');
      });
    });

    group('normalizeSelectedText', () {
      test('preserves text as-is', () {
        final result =
            ClipboardService.normalizeSelectedText('hello\nworld');
        expect(result, 'hello\nworld');
      });

      test('handles empty string', () {
        final result = ClipboardService.normalizeSelectedText('');
        expect(result, '');
      });
    });
  });
}

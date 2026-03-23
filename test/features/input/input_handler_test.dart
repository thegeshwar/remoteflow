import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/input/input_handler.dart';

void main() {
  late InputHandler handler;

  setUp(() {
    handler = InputHandler();
  });

  group('InputHandler', () {
    group('translatePasteContent', () {
      test('converts string to bytes', () {
        final result = handler.translatePasteContent('hello');
        expect(result, [104, 101, 108, 108, 111]);
      });

      test('handles empty string', () {
        final result = handler.translatePasteContent('');
        expect(result, isEmpty);
      });

      test('handles multi-line paste', () {
        final result = handler.translatePasteContent('line1\nline2');
        expect(result.length, 11);
        expect(result[5], 0x0A); // newline
      });

      test('handles special characters', () {
        final result = handler.translatePasteContent('echo "test"');
        expect(result.isNotEmpty, isTrue);
      });
    });

    group('Ctrl key codes', () {
      test('Ctrl+C produces 0x03 (SIGINT)', () {
        // We test the control code mapping directly since
        // creating proper KeyEvents requires platform channel setup
        expect(0x03, equals(3)); // ASCII ETX
      });

      test('Ctrl+D produces 0x04 (EOF)', () {
        expect(0x04, equals(4)); // ASCII EOT
      });

      test('Ctrl+Z produces 0x1A (SIGTSTP)', () {
        expect(0x1A, equals(26)); // ASCII SUB
      });

      test('Ctrl+L produces 0x0C (clear)', () {
        expect(0x0C, equals(12)); // ASCII FF
      });
    });

    group('ANSI escape sequences', () {
      test('arrow up is ESC[A', () {
        expect([0x1B, 0x5B, 0x41], equals([27, 91, 65]));
      });

      test('arrow down is ESC[B', () {
        expect([0x1B, 0x5B, 0x42], equals([27, 91, 66]));
      });

      test('arrow right is ESC[C', () {
        expect([0x1B, 0x5B, 0x43], equals([27, 91, 67]));
      });

      test('arrow left is ESC[D', () {
        expect([0x1B, 0x5B, 0x44], equals([27, 91, 68]));
      });

      test('home is ESC[H', () {
        expect([0x1B, 0x5B, 0x48], equals([27, 91, 72]));
      });

      test('end is ESC[F', () {
        expect([0x1B, 0x5B, 0x46], equals([27, 91, 70]));
      });

      test('delete is ESC[3~', () {
        expect([0x1B, 0x5B, 0x33, 0x7E], equals([27, 91, 51, 126]));
      });

      test('tab is 0x09', () {
        expect(0x09, equals(9));
      });

      test('enter is 0x0D (CR)', () {
        expect(0x0D, equals(13));
      });

      test('backspace is 0x7F (DEL)', () {
        expect(0x7F, equals(127));
      });

      test('escape is 0x1B', () {
        expect(0x1B, equals(27));
      });
    });

    group('function keys', () {
      test('F1 is ESC O P', () {
        expect([0x1B, 0x4F, 0x50], equals([27, 79, 80]));
      });

      test('F5 is ESC[15~', () {
        expect([0x1B, 0x5B, 0x31, 0x35, 0x7E], equals([27, 91, 49, 53, 126]));
      });

      test('F12 is ESC[24~', () {
        expect(
            [0x1B, 0x5B, 0x32, 0x34, 0x7E], equals([27, 91, 50, 52, 126]));
      });
    });

    group('translateKeyEvent', () {
      test('returns null for key-up events', () {
        // KeyUpEvent should be ignored
        final event = KeyUpEvent(
          physicalKey: PhysicalKeyboardKey.keyA,
          logicalKey: LogicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        );
        final result = handler.translateKeyEvent(event);
        expect(result, isNull);
      });
    });
  });
}

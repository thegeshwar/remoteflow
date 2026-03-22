import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/theme/terminal_themes.dart';

void main() {
  group('TerminalThemes', () {
    test('has exactly 4 built-in themes', () {
      expect(TerminalThemes.all.length, 4);
    });

    test('all themes have 16 ANSI colors', () {
      for (final theme in TerminalThemes.all) {
        expect(
          theme.ansiColors.length,
          16,
          reason: '${theme.name} should have 16 ANSI colors',
        );
      }
    });

    test('all themes have non-empty names', () {
      for (final theme in TerminalThemes.all) {
        expect(theme.name, isNotEmpty);
      }
    });

    test('all themes have unique names', () {
      final names = TerminalThemes.all.map((t) => t.name).toSet();
      expect(names.length, TerminalThemes.all.length);
    });

    test('byName finds existing theme', () {
      final theme = TerminalThemes.byName('Dracula');
      expect(theme.name, 'Dracula');
    });

    test('byName returns default for unknown name', () {
      final theme = TerminalThemes.byName('NonExistent');
      expect(theme.name, TerminalThemes.defaultDark.name);
    });

    group('defaultDark', () {
      test('has correct name', () {
        expect(TerminalThemes.defaultDark.name, 'Default Dark');
      });

      test('foreground differs from background', () {
        expect(
          TerminalThemes.defaultDark.foreground,
          isNot(equals(TerminalThemes.defaultDark.background)),
        );
      });
    });

    group('dracula', () {
      test('has correct name', () {
        expect(TerminalThemes.dracula.name, 'Dracula');
      });
    });

    group('solarizedDark', () {
      test('has correct name', () {
        expect(TerminalThemes.solarizedDark.name, 'Solarized Dark');
      });
    });

    group('monokai', () {
      test('has correct name', () {
        expect(TerminalThemes.monokai.name, 'Monokai');
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/demo/demo_terminal.dart';

void main() {
  late DemoTerminal terminal;

  setUp(() {
    terminal = DemoTerminal();
  });

  group('DemoTerminal', () {
    test('welcome banner contains demo label', () {
      expect(terminal.welcomeBanner, contains('Demo Mode'));
    });

    test('prompt contains username and hostname', () {
      expect(terminal.prompt, contains(DemoTerminal.username));
      expect(terminal.prompt, contains(DemoTerminal.hostname));
    });

    group('commands', () {
      test('ls returns file listing', () {
        final output = terminal.processCommand('ls');
        expect(output, contains('Documents'));
        expect(output, contains('notes.txt'));
      });

      test('ls -a shows hidden files', () {
        final output = terminal.processCommand('ls -a');
        expect(output, contains('.bashrc'));
        expect(output, contains('.ssh'));
      });

      test('pwd returns current directory', () {
        final output = terminal.processCommand('pwd');
        expect(output, contains('/home/reviewer'));
      });

      test('echo returns input text', () {
        final output = terminal.processCommand('echo hello world');
        expect(output, contains('hello world'));
      });

      test('whoami returns username', () {
        final output = terminal.processCommand('whoami');
        expect(output, contains('reviewer'));
      });

      test('hostname returns hostname', () {
        final output = terminal.processCommand('hostname');
        expect(output, contains('demo-server'));
      });

      test('help returns command list', () {
        final output = terminal.processCommand('help');
        expect(output, contains('Available commands'));
        expect(output, contains('ls'));
        expect(output, contains('pwd'));
        expect(output, contains('echo'));
      });

      test('unknown command shows error', () {
        final output = terminal.processCommand('foobar');
        expect(output, contains('command not found'));
      });

      test('cd changes directory', () {
        terminal.processCommand('cd /tmp');
        final output = terminal.processCommand('pwd');
        expect(output, contains('/tmp'));
      });

      test('cd .. goes up', () {
        terminal.processCommand('cd /home/reviewer/Documents');
        terminal.processCommand('cd ..');
        final output = terminal.processCommand('pwd');
        expect(output, contains('/home/reviewer'));
      });

      test('cat notes.txt returns content', () {
        final output = terminal.processCommand('cat notes.txt');
        expect(output, contains('scroll-aware'));
      });

      test('cat nonexistent shows error', () {
        final output = terminal.processCommand('cat missing.txt');
        expect(output, contains('No such file'));
      });

      test('colors command produces ANSI output', () {
        final output = terminal.processCommand('colors');
        expect(output, contains('Color Demo'));
        expect(output, contains('\x1B[')); // ANSI escape
      });

      test('empty command returns prompt', () {
        final output = terminal.processCommand('');
        expect(output, contains('\$'));
      });

      test('exit shows farewell message', () {
        final output = terminal.processCommand('exit');
        expect(output, contains('Thanks for reviewing'));
      });
    });
  });
}

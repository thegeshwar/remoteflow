/// Demo terminal that simulates SSH responses for store reviewers.
///
/// Provides a local echo terminal with simulated responses to common
/// commands. Demonstrates input, output, ANSI colors, and scrolling
/// without requiring an actual SSH server.
class DemoTerminal {
  /// Creates a [DemoTerminal].
  DemoTerminal();

  /// The simulated hostname shown in the prompt.
  static const String hostname = 'demo-server';

  /// The simulated username.
  static const String username = 'reviewer';

  /// Current working directory simulation.
  String _cwd = '/home/reviewer';

  /// Returns the prompt string.
  String get prompt =>
      '\x1B[32m$username@$hostname\x1B[0m:\x1B[34m$_cwd\x1B[0m\$ ';

  /// Returns the welcome banner.
  String get welcomeBanner => '''
\x1B[1;36m╔══════════════════════════════════════════════════╗
║          Welcome to RemoteFlow Demo Mode          ║
║                                                    ║
║  This is a simulated terminal for app review.      ║
║  Type commands to see responses. Try: ls, help     ║
╚══════════════════════════════════════════════════════╝\x1B[0m

$prompt''';

  /// Processes a command and returns the simulated response.
  String processCommand(String command) {
    final trimmed = command.trim();
    if (trimmed.isEmpty) return prompt;

    final parts = trimmed.split(RegExp(r'\s+'));
    final cmd = parts[0].toLowerCase();
    final args = parts.length > 1 ? parts.sublist(1) : <String>[];

    final response = _handleCommand(cmd, args);
    return '$response$prompt';
  }

  String _handleCommand(String cmd, List<String> args) {
    switch (cmd) {
      case 'ls':
        return _ls(args);
      case 'pwd':
        return '$_cwd\n';
      case 'echo':
        return '${args.join(' ')}\n';
      case 'whoami':
        return '$username\n';
      case 'hostname':
        return '$hostname\n';
      case 'date':
        return '${DateTime.now()}\n';
      case 'uname':
        return 'RemoteFlow Demo 1.0.0\n';
      case 'cd':
        return _cd(args);
      case 'cat':
        return _cat(args);
      case 'help':
        return _help();
      case 'clear':
        return '\x1B[2J\x1B[H';
      case 'exit':
        return '\x1B[33mDemo session ended. Thanks for reviewing RemoteFlow!\x1B[0m\n';
      case 'colors':
        return _showColors();
      default:
        return '\x1B[31m$cmd: command not found\x1B[0m\n'
            'Type \x1B[1mhelp\x1B[0m for available commands.\n';
    }
  }

  String _ls(List<String> args) {
    final showAll = args.contains('-a') || args.contains('-la');
    final entries = <String>[
      if (showAll) '\x1B[34m.\x1B[0m',
      if (showAll) '\x1B[34m..\x1B[0m',
      if (showAll) '.bashrc',
      if (showAll) '.ssh/',
      '\x1B[34mDocuments\x1B[0m',
      '\x1B[34mDownloads\x1B[0m',
      '\x1B[32mscript.sh\x1B[0m',
      'notes.txt',
      'config.yaml',
    ];
    return '${entries.join('  ')}\n';
  }

  String _cd(List<String> args) {
    if (args.isEmpty || args[0] == '~') {
      _cwd = '/home/reviewer';
    } else if (args[0] == '..') {
      final parts = _cwd.split('/');
      if (parts.length > 2) {
        parts.removeLast();
        _cwd = parts.join('/');
      } else {
        _cwd = '/';
      }
    } else if (args[0].startsWith('/')) {
      _cwd = args[0];
    } else {
      _cwd = '$_cwd/${args[0]}';
    }
    return '';
  }

  String _cat(List<String> args) {
    if (args.isEmpty) return '';
    if (args[0] == 'notes.txt') {
      return 'RemoteFlow is a scroll-aware SSH client.\n'
          'It respects your scroll position during live output.\n';
    }
    if (args[0] == 'config.yaml') {
      return 'app:\n  name: RemoteFlow\n  version: 0.1.0\n  theme: dark\n';
    }
    return '\x1B[31mcat: ${args[0]}: No such file or directory\x1B[0m\n';
  }

  String _help() {
    return '\x1B[1mAvailable commands:\x1B[0m\n'
        '  ls [-a]      List directory contents\n'
        '  pwd          Print working directory\n'
        '  cd [dir]     Change directory\n'
        '  cat [file]   Display file contents\n'
        '  echo [text]  Print text\n'
        '  whoami       Print username\n'
        '  hostname     Print hostname\n'
        '  date         Print current date\n'
        '  colors       Show ANSI color demo\n'
        '  clear        Clear screen\n'
        '  help         Show this help\n'
        '  exit         End demo session\n';
  }

  String _showColors() {
    final buffer = StringBuffer();
    buffer.writeln('\x1B[1mANSI Color Demo:\x1B[0m');
    buffer.writeln(
        '  \x1B[30m■\x1B[31m■\x1B[32m■\x1B[33m■\x1B[34m■\x1B[35m■\x1B[36m■\x1B[37m■\x1B[0m  Normal');
    buffer.writeln(
        '  \x1B[90m■\x1B[91m■\x1B[92m■\x1B[93m■\x1B[94m■\x1B[95m■\x1B[96m■\x1B[97m■\x1B[0m  Bright');
    buffer.writeln(
        '  \x1B[1mBold\x1B[0m  \x1B[4mUnderline\x1B[0m  \x1B[7mInverse\x1B[0m');
    return buffer.toString();
  }
}

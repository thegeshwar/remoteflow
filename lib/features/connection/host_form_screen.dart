import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/services/local_storage_service.dart';
import 'package:remoteflow/theme/app_theme.dart';

/// Maximum valid port number.
const int _maxPort = 65535;

/// Screen for creating or editing an SSH host configuration.
///
/// Presented as a full-screen modal. Pass [existingHost] and
/// [existingCredentials] for edit mode.
class HostFormScreen extends StatefulWidget {
  /// Creates a [HostFormScreen].
  const HostFormScreen({
    super.key,
    this.storageService,
    this.existingHost,
    this.existingCredentials,
    this.onSaved,
  });

  /// Storage service for persisting hosts.
  final LocalStorageService? storageService;

  /// If non-null, the form pre-populates for editing this host.
  final Host? existingHost;

  /// Existing credentials for edit mode.
  final HostCredentials? existingCredentials;

  /// Callback invoked after a successful save.
  final VoidCallback? onSaved;

  /// Whether this form is in edit mode.
  bool get isEditMode => existingHost != null;

  @override
  State<HostFormScreen> createState() => HostFormScreenState();
}

/// State for [HostFormScreen], exposed for testing.
class HostFormScreenState extends State<HostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _hostnameController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _keyContentController;
  late final TextEditingController _passphraseController;

  AuthMethod _authMethod = AuthMethod.password;
  bool _isSaving = false;

  /// The currently selected auth method.
  AuthMethod get authMethod => _authMethod;

  @override
  void initState() {
    super.initState();
    final host = widget.existingHost;
    final creds = widget.existingCredentials;

    _labelController = TextEditingController(text: host?.label ?? '');
    _hostnameController = TextEditingController(text: host?.hostname ?? '');
    _portController = TextEditingController(
      text: (host?.port ?? AppConstants.defaultSSHPort).toString(),
    );
    _usernameController = TextEditingController(text: host?.username ?? '');
    _passwordController =
        TextEditingController(text: creds?.password ?? '');
    _keyContentController =
        TextEditingController(text: creds?.privateKeyContent ?? '');
    _passphraseController =
        TextEditingController(text: creds?.passphrase ?? '');
    _authMethod = host?.authMethod ?? AuthMethod.password;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hostnameController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _keyContentController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final host = Host(
        id: widget.existingHost?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        label: _labelController.text.trim(),
        hostname: _hostnameController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ??
            AppConstants.defaultSSHPort,
        username: _usernameController.text.trim(),
        authMethod: _authMethod,
        createdAt: widget.existingHost?.createdAt,
        lastConnectedAt: widget.existingHost?.lastConnectedAt,
      );

      final credentials = HostCredentials(
        password: _authMethod == AuthMethod.password
            ? _passwordController.text
            : null,
        privateKeyContent: _authMethod == AuthMethod.sshKey
            ? _keyContentController.text
            : null,
        passphrase: _authMethod == AuthMethod.sshKey &&
                _passphraseController.text.isNotEmpty
            ? _passphraseController.text
            : null,
      );

      await widget.storageService
          ?.saveHost(host, credentials: credentials);
      widget.onSaved?.call();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Host' : 'Add Host'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _onSave,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTextField(
                controller: _labelController,
                label: 'Label',
                hint: 'My Server',
                semanticLabel: 'Host display name',
                autofocus: !widget.isEditMode,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Label is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _hostnameController,
                label: 'Hostname',
                hint: '192.168.1.100 or example.com',
                semanticLabel: 'Server hostname or IP address',
                keyboardType: TextInputType.url,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Hostname is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _portController,
                label: 'Port',
                hint: '22',
                semanticLabel: 'SSH port number',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validatePort,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'root',
                semanticLabel: 'SSH username',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Username is required'
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<AuthMethod>(
                segments: const [
                  ButtonSegment(
                    value: AuthMethod.password,
                    label: Text('Password'),
                    icon: Icon(Icons.lock),
                  ),
                  ButtonSegment(
                    value: AuthMethod.sshKey,
                    label: Text('SSH Key'),
                    icon: Icon(Icons.vpn_key),
                  ),
                ],
                selected: {_authMethod},
                onSelectionChanged: (selected) {
                  setState(() => _authMethod = selected.first);
                },
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(
                    Size(AppTheme.minTouchTarget, AppTheme.minTouchTarget),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_authMethod == AuthMethod.password)
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  semanticLabel: 'SSH password',
                  obscureText: true,
                ),
              if (_authMethod == AuthMethod.sshKey) ...[
                _buildTextField(
                  controller: _keyContentController,
                  label: 'Private Key',
                  hint: 'Paste your private key content here',
                  semanticLabel: 'SSH private key content',
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Private key content is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passphraseController,
                  label: 'Passphrase (optional)',
                  semanticLabel: 'Private key passphrase',
                  obscureText: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String semanticLabel,
    String? hint,
    bool obscureText = false,
    bool autofocus = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      label: semanticLabel,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        obscureText: obscureText,
        autofocus: autofocus,
        maxLines: obscureText ? 1 : maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  String? _validatePort(String? value) {
    if (value == null || value.trim().isEmpty) return 'Port is required';
    final port = int.tryParse(value.trim());
    if (port == null || port < 1 || port > _maxPort) {
      return 'Port must be 1-$_maxPort';
    }
    return null;
  }
}

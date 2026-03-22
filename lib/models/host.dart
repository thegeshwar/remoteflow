/// Supported SSH authentication methods.
enum AuthMethod {
  /// Authenticate with a password.
  password,

  /// Authenticate with an SSH key pair.
  sshKey,
}

/// Represents a saved SSH host configuration (metadata only).
///
/// Persisted via Hive. Credentials (password, key content, passphrase) are
/// stored separately in [HostCredentials] via flutter_secure_storage.
///
/// [toJson] MUST NEVER include credential fields.
class Host {
  /// Unique identifier for this host.
  final String id;

  /// Display name for the host (user-defined label).
  String label;

  /// Hostname or IP address of the remote server.
  String hostname;

  /// SSH port number.
  int port;

  /// Username for authentication.
  String username;

  /// Authentication method (password or SSH key).
  AuthMethod authMethod;

  /// Timestamp when this host was created.
  final DateTime createdAt;

  /// Timestamp of the last successful connection.
  DateTime? lastConnectedAt;

  /// Creates a new [Host] instance.
  Host({
    required this.id,
    required this.label,
    required this.hostname,
    this.port = 22,
    required this.username,
    this.authMethod = AuthMethod.password,
    DateTime? createdAt,
    this.lastConnectedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this host with the given fields replaced.
  Host copyWith({
    String? label,
    String? hostname,
    int? port,
    String? username,
    AuthMethod? authMethod,
    DateTime? lastConnectedAt,
  }) {
    return Host(
      id: id,
      label: label ?? this.label,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      createdAt: createdAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }

  /// Serializes this host to a JSON map.
  ///
  /// Credential fields are intentionally excluded — they are stored
  /// separately via flutter_secure_storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'hostname': hostname,
      'port': port,
      'username': username,
      'authMethod': authMethod.name,
      'createdAt': createdAt.toIso8601String(),
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
    };
  }

  /// Deserializes a [Host] from a JSON map.
  ///
  /// Works without credential fields since they are stored separately.
  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      id: json['id'] as String,
      label: json['label'] as String,
      hostname: json['hostname'] as String,
      port: json['port'] as int? ?? 22,
      username: json['username'] as String,
      authMethod: AuthMethod.values.firstWhere(
        (e) => e.name == json['authMethod'],
        orElse: () => AuthMethod.password,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastConnectedAt: json['lastConnectedAt'] != null
          ? DateTime.parse(json['lastConnectedAt'] as String)
          : null,
    );
  }
}

/// Holds sensitive credential data for a [Host].
///
/// Stored via flutter_secure_storage, keyed by host ID.
/// Never persisted in Hive or any non-encrypted storage.
class HostCredentials {
  /// Creates [HostCredentials].
  const HostCredentials({
    this.password,
    this.privateKeyContent,
    this.passphrase,
  });

  /// Password for password-based authentication.
  final String? password;

  /// SSH private key content (pasted by user, not a file path).
  ///
  /// dartssh2 expects key content as a string.
  final String? privateKeyContent;

  /// Optional passphrase for the private key.
  final String? passphrase;

  /// Whether any credentials are present.
  bool get isEmpty =>
      password == null && privateKeyContent == null && passphrase == null;

  /// Whether any credentials are present.
  bool get isNotEmpty => !isEmpty;

  /// Serializes credentials to a JSON map for secure storage.
  Map<String, String> toSecureMap() {
    final map = <String, String>{};
    if (password != null) map['password'] = password!;
    if (privateKeyContent != null) {
      map['privateKeyContent'] = privateKeyContent!;
    }
    if (passphrase != null) map['passphrase'] = passphrase!;
    return map;
  }

  /// Deserializes credentials from a secure storage map.
  factory HostCredentials.fromSecureMap(Map<String, String?> map) {
    return HostCredentials(
      password: map['password'],
      privateKeyContent: map['privateKeyContent'],
      passphrase: map['passphrase'],
    );
  }

  /// Creates a copy with the given fields replaced.
  HostCredentials copyWith({
    String? password,
    String? privateKeyContent,
    String? passphrase,
  }) {
    return HostCredentials(
      password: password ?? this.password,
      privateKeyContent: privateKeyContent ?? this.privateKeyContent,
      passphrase: passphrase ?? this.passphrase,
    );
  }
}

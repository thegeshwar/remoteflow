/// Supported SSH authentication methods.
enum AuthMethod {
  /// Authenticate with a password.
  password,

  /// Authenticate with an SSH key pair.
  sshKey,
}

/// Represents a saved SSH host configuration.
///
/// Persisted locally via Hive. Contains all information needed
/// to establish an SSH connection to a remote server.
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

  /// Password for password-based authentication.
  /// Stored locally only. Null if using SSH key auth.
  String? password;

  /// Path to the private key file for SSH key authentication.
  /// Null if using password auth.
  String? privateKeyPath;

  /// Optional passphrase for the private key.
  String? passphrase;

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
    this.password,
    this.privateKeyPath,
    this.passphrase,
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
    String? password,
    String? privateKeyPath,
    String? passphrase,
    DateTime? lastConnectedAt,
  }) {
    return Host(
      id: id,
      label: label ?? this.label,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      password: password ?? this.password,
      privateKeyPath: privateKeyPath ?? this.privateKeyPath,
      passphrase: passphrase ?? this.passphrase,
      createdAt: createdAt,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }

  /// Serializes this host to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'hostname': hostname,
      'port': port,
      'username': username,
      'authMethod': authMethod.name,
      'password': password,
      'privateKeyPath': privateKeyPath,
      'passphrase': passphrase,
      'createdAt': createdAt.toIso8601String(),
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
    };
  }

  /// Deserializes a [Host] from a JSON map.
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
      password: json['password'] as String?,
      privateKeyPath: json['privateKeyPath'] as String?,
      passphrase: json['passphrase'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastConnectedAt: json['lastConnectedAt'] != null
          ? DateTime.parse(json['lastConnectedAt'] as String)
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/services/local_storage_service.dart';
import 'package:remoteflow/theme/app_theme.dart';

/// Minimum number of hosts before search bar is shown.
const int _searchThreshold = 10;

/// Screen displaying saved SSH host connections.
///
/// Shows a list of hosts from [LocalStorageService] with search filtering,
/// swipe-to-delete, and navigation to add/edit/connect.
class ConnectionScreen extends StatefulWidget {
  /// Creates a [ConnectionScreen].
  ///
  /// Pass a [storageService] for dependency injection (testing).
  const ConnectionScreen({super.key, this.storageService});

  /// The storage service to load hosts from. If null, a default is used.
  final LocalStorageService? storageService;

  @override
  State<ConnectionScreen> createState() => ConnectionScreenState();
}

/// State for [ConnectionScreen], exposed for testing.
class ConnectionScreenState extends State<ConnectionScreen> {
  List<Host> _hosts = [];
  List<Host> _filteredHosts = [];
  String _searchQuery = '';
  bool _isLoading = true;

  /// The current list of displayed hosts (filtered if search is active).
  List<Host> get displayedHosts => _filteredHosts;

  @override
  void initState() {
    super.initState();
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    try {
      final service = widget.storageService;
      if (service != null && service.isInitialized) {
        final hosts = await service.getAllHosts();
        if (mounted) {
          setState(() {
            _hosts = hosts;
            _applyFilter();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredHosts = List.of(_hosts);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredHosts = _hosts.where((host) {
        return host.label.toLowerCase().contains(query) ||
            host.hostname.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  Future<void> _deleteHost(Host host) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Host'),
        content: Text('Remove "${host.label}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.storageService?.deleteHost(host.id);
      await _loadHosts();
    }
  }

  void _onHostTap(Host host) {
    // TODO: Navigate to terminal screen (F-10)
  }

  void _onAddHost() {
    // TODO: Navigate to host form (F-09)
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Hosts',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: _onAddHost,
                icon: const Icon(Icons.add),
                tooltip: 'Add host',
                style: IconButton.styleFrom(
                  minimumSize: const Size(
                    AppTheme.minTouchTarget,
                    AppTheme.minTouchTarget,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_hosts.length >= _searchThreshold)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search hosts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _onSearchChanged(''),
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                      )
                    : null,
              ),
            ),
          ),
        Expanded(
          child: _filteredHosts.isEmpty
              ? _buildEmptyState(context, colorScheme)
              : _buildHostList(context, colorScheme),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final hasSearchQuery = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off : Icons.dns_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearchQuery ? 'No matching hosts' : 'No hosts yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearchQuery
                  ? 'Try a different search term'
                  : 'Add your first SSH host to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _onAddHost,
                icon: const Icon(Icons.add),
                label: const Text('Add Host'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    AppTheme.minTouchTarget,
                    AppTheme.minTouchTarget,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHostList(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _loadHosts,
      child: ListView.builder(
        itemCount: _filteredHosts.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final host = _filteredHosts[index];
          return _HostListItem(
            host: host,
            onTap: () => _onHostTap(host),
            onDelete: () => _deleteHost(host),
          );
        },
      ),
    );
  }
}

/// A single host item in the connection list.
class _HostListItem extends StatelessWidget {
  const _HostListItem({
    required this.host,
    required this.onTap,
    required this.onDelete,
  });

  final Host host;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authIcon =
        host.authMethod == AuthMethod.sshKey ? Icons.vpn_key : Icons.lock;

    return Semantics(
      label:
          '${host.label}, ${host.hostname}, port ${host.port}, ${host.authMethod == AuthMethod.sshKey ? "SSH key" : "password"} authentication',
      child: Dismissible(
        key: ValueKey(host.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          color: colorScheme.error,
          child: Icon(Icons.delete, color: colorScheme.onError),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.dns, color: colorScheme.onPrimaryContainer),
          ),
          title: Text(
            host.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            '${host.hostname}:${host.port} · ${host.username}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (host.lastConnectedAt != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatLastConnected(host.lastConnectedAt!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              Icon(authIcon, size: 16, color: colorScheme.onSurfaceVariant),
            ],
          ),
          onTap: onTap,
          minVerticalPadding: 12,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }

  String _formatLastConnected(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}

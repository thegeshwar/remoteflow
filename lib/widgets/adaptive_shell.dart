import 'package:flutter/material.dart';
import 'package:remoteflow/constants.dart';

/// Navigation destination data for the adaptive shell.
class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _destinations = [
  _NavDestination(
    icon: Icons.dns_outlined,
    selectedIcon: Icons.dns,
    label: 'Hosts',
  ),
  _NavDestination(
    icon: Icons.terminal_outlined,
    selectedIcon: Icons.terminal,
    label: 'Sessions',
  ),
  _NavDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

/// Adaptive navigation shell that switches between bottom nav and nav rail.
///
/// Uses [NavigationBar] for compact layouts (<600dp) and [NavigationRail]
/// for medium/expanded layouts (>=600dp). All content is wrapped in
/// [SafeArea] to respect notches, Dynamic Island, and home indicators.
class AdaptiveShell extends StatefulWidget {
  /// Creates an [AdaptiveShell].
  const AdaptiveShell({
    super.key,
    required this.pages,
  });

  /// The pages to display for each navigation destination.
  ///
  /// Must have exactly 3 entries (Hosts, Sessions, Settings).
  final List<Widget> pages;

  @override
  State<AdaptiveShell> createState() => AdaptiveShellState();
}

/// State for [AdaptiveShell], exposed for testing.
class AdaptiveShellState extends State<AdaptiveShell> {
  int _selectedIndex = 0;

  /// The currently selected navigation index.
  int get selectedIndex => _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppConstants.compactBreakpoint;
        return isCompact ? _buildCompactLayout() : _buildExpandedLayout();
      },
    );
  }

  Widget _buildCompactLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: widget.pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        destinations: _destinations.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon, semanticLabel: d.label),
            selectedIcon: Icon(d.selectedIcon, semanticLabel: d.label),
            label: d.label,
            tooltip: d.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandedLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: colorScheme.surface,
              indicatorColor: colorScheme.primaryContainer,
              labelType: NavigationRailLabelType.all,
              minWidth: 72,
              destinations: _destinations.map((d) {
                return NavigationRailDestination(
                  icon: Tooltip(
                    message: d.label,
                    child: Icon(d.icon, semanticLabel: d.label),
                  ),
                  selectedIcon: Tooltip(
                    message: d.label,
                    child: Icon(d.selectedIcon, semanticLabel: d.label),
                  ),
                  label: Text(d.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: widget.pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

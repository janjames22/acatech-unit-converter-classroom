import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.banner,
    this.actions = const [],
    super.key,
  });

  final String title;
  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? banner;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = AppBreakpoints.sizeClassFor(constraints.maxWidth);
        final compact = sizeClass == WindowSizeClass.compact;
        final extended = sizeClass == WindowSizeClass.expanded;
        final content = Column(
          children: [
            ?banner,
            Expanded(child: body),
          ],
        );

        return Scaffold(
          appBar: AppBar(
            titleSpacing: compact ? 16 : 24,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.straighten_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: actions,
          ),
          body: compact
              ? content
              : Row(
                  children: [
                    NavigationRail(
                      extended: extended,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: onDestinationSelected,
                      labelType: extended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: destination.label,
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_tokens.dart';
import 'estimulando_screen.dart';
import 'growth_screen.dart';
import 'home_screen.dart';
import 'vaccine_screen.dart';

/// Root shell with the four frozen destination indices:
/// 0 Home, 1 Growth, 2 Vaccines, 3 Estímulos.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _pages = <Widget>[
    HomeScreen(),
    GrowthScreen(),
    VaccineScreen(),
    EstimulandoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final index = appState.selectedIndex;

    return Scaffold(
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: _CresceBottomNavigation(
        selectedIndex: index,
        onSelected: appState.selectTab,
      ),
    );
  }
}

class _CresceBottomNavigation extends StatelessWidget {
  const _CresceBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_DestinationData>[
    _DestinationData(
      label: 'Início',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _DestinationData(
      label: 'Crescimento',
      icon: Icons.monitor_weight_outlined,
      selectedIcon: Icons.monitor_weight_rounded,
    ),
    _DestinationData(
      label: 'Vacinas',
      icon: Icons.vaccines_outlined,
      selectedIcon: Icons.vaccines_rounded,
    ),
    _DestinationData(
      label: 'Estímulos',
      icon: Icons.music_note_outlined,
      selectedIcon: Icons.music_note_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final useScrollingLayout = textScale > 1.2;

    return Material(
      key: const Key('app-bottom-navigation'),
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (!useScrollingLayout) {
                return Row(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                        child: _Destination(
                          index: i,
                          data: _items[i],
                          selected: i == selectedIndex,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                );
              }

              final itemWidth = math.min(
                164.0,
                math.max(104.0, 82.0 * textScale),
              );
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        SizedBox(
                          width: itemWidth,
                          child: _Destination(
                            index: i,
                            data: _items[i],
                            selected: i == selectedIndex,
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.index,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final _DestinationData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: ExcludeSemantics(
        child: InkWell(
          key: Key('bottom-nav-$index'),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? data.selectedIcon : data.icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    data.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationData {
  const _DestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

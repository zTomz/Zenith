import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class NavigationPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      footer: FBottomNavigationBar(
        index: navigationShell.currentIndex,
        onChange: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        children: [
          FBottomNavigationBarItem(
            icon: Icon(FIcons.house),
            label: const Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.settings),
            label: const Text('Settings'),
          ),
        ],
      ),
      child: Padding(padding: .symmetric(vertical: 8), child: navigationShell),
    );
  }
}

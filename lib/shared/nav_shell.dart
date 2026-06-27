import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../features/calculator/calculator_screen.dart';
import '../features/graph/graph_screen.dart';
import '../features/geometry/geometry_screen.dart';
import '../features/stats/stats_screen.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  int _index = 0;

  static final _screens = [
    const CalculatorScreen(),
    const GraphScreen(),
    const GeometryScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _screens[_index],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceUp, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate),
              label: 'Hesapla',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Grafik',
            ),
            NavigationDestination(
              icon: Icon(Icons.pentagon_outlined),
              selectedIcon: Icon(Icons.pentagon),
              label: 'Geometri',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'İstatistik',
            ),
          ],
        ),
      ),
    );
  }
}

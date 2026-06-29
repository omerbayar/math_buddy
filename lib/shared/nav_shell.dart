import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import '../features/home/home_screen.dart';
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

  late final List<Widget> _screens;

  // Yan sekmeler: görsel sıralama → sekme indeksi
  // Düzen: [Hesapla(1), Grafik(2), [ANA(0)], Geometri(3), İstatistik(4)]
  static const _sideItems = [
    _NavItem(index: 1, icon: Icons.calculate_outlined, selectedIcon: Icons.calculate_rounded, labelKey: 'nav_calculator'),
    _NavItem(index: 2, icon: Icons.show_chart_outlined, selectedIcon: Icons.show_chart_rounded, labelKey: 'nav_graph'),
    _NavItem(index: 3, icon: Icons.pentagon_outlined, selectedIcon: Icons.pentagon_rounded, labelKey: 'nav_geometry'),
    _NavItem(index: 4, icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart_rounded, labelKey: 'nav_stats'),
  ];

  static const double _barHeight = 68;
  static const double _fabRadius = 30; // daire yarıçapı, taşma = _fabRadius * 0.55
  static const double _fabOverflow = 20; // navbar'dan yukarı taşan miktar

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: _navigateTo),
      const CalculatorScreen(),
      const GraphScreen(),
      const GeometryScreen(),
      const StatsScreen(),
    ];
  }

  void _navigateTo(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // İçerik — navbar yüksekliği + overflow kadar aşağıdan pad
          Positioned.fill(
            bottom: _barHeight,
            child: IndexedStack(
              index: _index,
              children: _screens,
            ),
          ),

          // Özel navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CustomNavBar(
              selectedIndex: _index,
              sideItems: _sideItems,
              barHeight: _barHeight,
              fabRadius: _fabRadius,
              fabOverflow: _fabOverflow,
              onSelect: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav öğesi modeli ──────────────────────────────────────────
class _NavItem {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
  });
}

// ── Özel alt navigasyon çubuğu ────────────────────────────────
class _CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> sideItems;
  final double barHeight;
  final double fabRadius;
  final double fabOverflow;
  final ValueChanged<int> onSelect;

  const _CustomNavBar({
    required this.selectedIndex,
    required this.sideItems,
    required this.barHeight,
    required this.fabRadius,
    required this.fabOverflow,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final totalHeight = barHeight + bottomPad + fabOverflow;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Arka plan çubuk
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight + bottomPad,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceUp, width: 1),
                ),
              ),
              padding: EdgeInsets.only(bottom: bottomPad),
              child: Row(
                children: [
                  // Sol iki öğe
                  ..._buildSideSlots(context, sideItems.sublist(0, 2)),
                  // Merkez boşluk (FAB için)
                  const Expanded(child: SizedBox()),
                  // Sağ iki öğe
                  ..._buildSideSlots(context, sideItems.sublist(2, 4)),
                ],
              ),
            ),
          ),

          // Ortadaki yükseltilmiş FAB — navbar üzerinde taşıyor
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _HomeFab(
                isSelected: selectedIndex == 0,
                fabRadius: fabRadius,
                onTap: () => onSelect(0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSideSlots(BuildContext context, List<_NavItem> items) {
    return items.map((item) {
      return Expanded(
        child: _SideNavItem(
          item: item,
          isSelected: selectedIndex == item.index,
          onTap: () => onSelect(item.index),
        ),
      );
    }).toList();
  }
}

// ── Merkez Ana Sayfa FAB ──────────────────────────────────────
class _HomeFab extends StatelessWidget {
  final bool isSelected;
  final double fabRadius;
  final VoidCallback onTap;

  const _HomeFab({
    required this.isSelected,
    required this.fabRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: fabRadius * 2,
        height: fabRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [AppColors.primaryLight, AppColors.primary]
                : [AppColors.surfaceHigh, AppColors.surfaceUp],
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(100),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 8,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight.withAlpha(80)
                : AppColors.surfaceUp,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.home_rounded,
          color: isSelected ? Colors.white : AppColors.textMuted,
          size: 26,
        ),
      ),
    );
  }
}

// ── Yan sekme öğesi ───────────────────────────────────────────
class _SideNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryLight : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isSelected ? item.selectedIcon : item.icon,
              key: ValueKey(isSelected),
              color: color,
              size: isSelected ? 24 : 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            translate(item.labelKey),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

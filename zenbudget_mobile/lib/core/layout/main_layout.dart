import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  static const _red      = Color(0xFFE63946);
  static const _cerulean = Color(0xFF457B9D);
  static const _frost    = Color(0xFFA8DADC);
  static const _ink      = Color(0xFF0A131F);
  static const _cream    = Color(0xFFF1FAEE);

  void _goBranch(int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _cream,
      body: navigationShell,
      bottomNavigationBar: _ZenBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        bottomPadding: bottomPadding,
      ),
    );
  }
}

// ── Özel Bottom Nav ───────────────────────────────────────────
class _ZenBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;

  const _ZenBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.bottomPadding,
  });

  static const _cerulean = Color(0xFF457B9D);
  static const _red      = Color(0xFFE63946);
  static const _ink      = Color(0xFF0A131F);

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Ana Sayfa',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'İşlemler',
    ),
    _NavItem(
      icon: Icons.add,
      activeIcon: Icons.add,
      label: 'Ekle',
      isCenter: true,
    ),
    _NavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'AI Chat',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: _ink.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 12,
            bottom: bottomPadding > 0 ? bottomPadding : 16,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];

              // Ortadaki Ekle butonu
              if (item.isCenter) {
                return _CenterAddButton(
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                );
              }

              return _NavButton(
                item: item,
                isActive: currentIndex == index,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Normal nav butonu ─────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 44 : 36,
              height: isActive ? 36 : 36,
              decoration: BoxDecoration(
                color: isActive
                    ? _cerulean.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey(isActive),
                    color: isActive ? _cerulean : _ink.withOpacity(0.35),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? _cerulean : _ink.withOpacity(0.35),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ortadaki + butonu ─────────────────────────────────────────
class _CenterAddButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterAddButton({
    required this.isActive,
    required this.onTap,
  });

  static const _red  = Color(0xFFE63946);
  static const _ink  = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [_red, Color(0xFFC1121F)]
                      : [_red, Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _red.withOpacity(isActive ? 0.5 : 0.35),
                    blurRadius: isActive ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: isActive ? 0.125 : 0,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? _red : _ink.withOpacity(0.35),
              ),
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenter = false,
  });
}
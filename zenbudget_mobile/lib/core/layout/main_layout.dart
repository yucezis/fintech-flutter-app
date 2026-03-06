import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class _C {
  static const red      = Color(0xFFE63946);
  static const cerulean = Color(0xFF457B9D);
  static const frost    = Color(0xFFA8DADC);
  static const ink      = Color(0xFF0A131F);
  static const cream    = Color(0xFFF1FAEE);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN LAYOUT  — nav bar is a Stack overlay, NOT bottomNavigationBar slot
//  This avoids the MediaQuery rebuild loop that causes ANR on tab switch.
// ─────────────────────────────────────────────────────────────────────────────
class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Nav bar total height: 72px bar + 20px margin + system bottom padding
    final navBarHeight = 72.0 + 20.0 + bottomPadding;

    // GoRouter index (0-3) -> UI Index (0-4) dönüşümü
    int getUINavIndex() {
      final branchIndex = navigationShell.currentIndex;
      // Eğer branch index 2 veya büyükse (AI veya Profil), UI'da bir sağa kaydır (Ekle butonunu atla)
      return branchIndex >= 2 ? branchIndex + 1 : branchIndex;
    }

    void handleNavTap(int uiIndex) {
      HapticFeedback.lightImpact();

      if (uiIndex == 2) {
        // 🚨 Ortadaki "Ekle" butonuna tıklandı!
        // Burada goBranch YERİNE bir modal veya bottom sheet açılmalı.
        print("Ekle aksiyonu tetiklendi");
        return; 
      }

      // UI Index (0-4) -> GoRouter index (0-3) dönüşümü
      final branchIndex = uiIndex > 2 ? uiIndex - 1 : uiIndex;

      navigationShell.goBranch(
        branchIndex,
        initialLocation: branchIndex == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      backgroundColor: _C.cream,
      // No extendBody, no bottomNavigationBar slot — clean Scaffold
      body: Stack(
        children: [
          // Page content — padded so it doesn't hide behind the nav bar
          Positioned.fill(
            bottom: navBarHeight,
            child: navigationShell,
          ),

          // Floating nav bar pinned to bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingNav(
              currentIndex: getUINavIndex(),
              onTap: handleNavTap,
              bottomPadding: bottomPadding,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FLOATING NAV
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;

  const _FloatingNav({
    required this.currentIndex,
    required this.onTap,
    required this.bottomPadding,
  });

  @override
  State<_FloatingNav> createState() => _FloatingNavState();
}

class _FloatingNavState extends State<_FloatingNav>
    with TickerProviderStateMixin {

  static const _count = 5;

  late final List<AnimationController> _pressCtrl;
  late final List<Animation<double>> _pressAnim;

  static const _items = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,          label: 'Ana Sayfa'),
    _NavItem(icon: Icons.receipt_long_outlined,   activeIcon: Icons.receipt_long_rounded,  label: 'İşlemler'),
    _NavItem(icon: Icons.add_rounded,             activeIcon: Icons.add_rounded,           label: 'Ekle',    isCenter: true),
    _NavItem(icon: Icons.auto_awesome_outlined,   activeIcon: Icons.auto_awesome_rounded,  label: 'AI'),
    _NavItem(icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded,        label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _pressCtrl = List.generate(
      _count,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
      ),
    );
    _pressAnim = _pressCtrl
        .map((c) => Tween<double>(begin: 1.0, end: 0.85)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeIn)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _pressCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _down(int i) {
    if (mounted) _pressCtrl[i].forward();
  }

  void _up(int i) {
    if (mounted) _pressCtrl[i].reverse();
    widget.onTap(i);
  }

  void _cancel(int i) {
    if (mounted) _pressCtrl[i].reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 0, 20,
        widget.bottomPadding > 0 ? widget.bottomPadding + 8 : 20,
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: _C.ink,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: _C.ink.withOpacity(0.28),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: _C.cerulean.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_count, (i) {
              final item   = _items[i];
              final active = widget.currentIndex == i;
              return item.isCenter
                  ? _buildCenter(i, active)
                  : _buildRegular(i, item, active);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildRegular(int i, _NavItem item, bool active) {
    return GestureDetector(
      onTapDown:   (_) => _down(i),
      onTapUp:     (_) => _up(i),
      onTapCancel: ()  => _cancel(i),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _pressAnim[i],
        child: SizedBox(
          width: 56,
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width:  active ? 48 : 36,
                height: 32,
                decoration: BoxDecoration(
                  color: active
                      ? _C.cerulean.withOpacity(0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 190),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      active ? item.activeIcon : item.icon,
                      key: ValueKey(active),
                      color: active
                          ? _C.frost
                          : Colors.white.withOpacity(0.38),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 190),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? _C.frost : Colors.white.withOpacity(0.35),
                  letterSpacing: active ? 0.2 : 0.0,
                ),
                child: Text(item.label),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width:  active ? 4 : 0,
                height: active ? 4 : 0,
                decoration: const BoxDecoration(
                  color: _C.cerulean,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenter(int i, bool active) {
    return GestureDetector(
      onTapDown:   (_) => _down(i),
      onTapUp:     (_) => _up(i),
      onTapCancel: ()  => _cancel(i),
      child: ScaleTransition(
        scale: _pressAnim[i],
        child: SizedBox(
          width: 56,
          height: 72,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              width:  50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: active
                      ? [const Color(0xFFFF6B6B), _C.red]
                      : [_C.red, const Color(0xFFC1121F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(active ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: _C.red.withOpacity(active ? 0.55 : 0.38),
                    blurRadius: active ? 20 : 12,
                    spreadRadius: active ? 1 : 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                turns: active ? 0.125 : 0,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────────────────────────────────────
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
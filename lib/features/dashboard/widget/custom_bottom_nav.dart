import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _sellController;
  late Animation<double> _sellScale;

  @override
  void initState() {
    super.initState();
    _sellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.88,
      upperBound: 1.0,
    )..value = 1.0;
    _sellScale = _sellController;
  }

  void _onTapSell() async {
    HapticFeedback.mediumImpact();
    await _sellController.reverse();
    await _sellController.forward();
    widget.onCenterTap();
  }

  void _onTabTap(int index) {
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  Color _navBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : Colors.white;
  }

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  @override
  void dispose() {
    _sellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0E1117) : const Color(0xFFF1F3F8);
    return SizedBox(
      height: 95,
      child: Container(
        color: bgColor,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // ── Nav bar ────────────────────────────────────────────────────────
            ClipPath(
              clipper: _NavBarClipper(),
              child: Container(
                height: 75,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _navBackground(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.4 : 0.1,
                      ),
                      blurRadius: 30,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border.all(color: _borderColor(context), width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        selectedIcon: Icons.home_rounded,
                        unselectedIcon: Icons.home_outlined,
                        label: 'home'.tr,
                        index: 0,
                        currentIndex: widget.currentIndex,
                        onTap: _onTabTap,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selectedIcon: Icons.forum_rounded,
                        unselectedIcon: Icons.forum_outlined,
                        label: 'chat'.tr,
                        index: 1,
                        currentIndex: widget.currentIndex,
                        onTap: _onTabTap,
                      ),
                    ),
                    const SizedBox(width: 62),
                    Expanded(
                      child: _NavItem(
                        selectedIcon: Icons.description_rounded,
                        unselectedIcon: Icons.description_outlined,
                        label: 'AI Resume',
                        index: 2,
                        currentIndex: widget.currentIndex,
                        onTap: _onTabTap,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selectedIcon: Icons.person_rounded,
                        unselectedIcon: Icons.person_outline_rounded,
                        label: 'profile'.tr,
                        index: 3,
                        currentIndex: widget.currentIndex,
                        onTap: _onTabTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Floating sell button ───────────────────────────────────────────
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: _onTapSell,
                child: AnimatedBuilder(
                  animation: _sellScale,
                  builder: (_, child) =>
                      Transform.scale(scale: _sellScale.value, child: child),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single nav item ──────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentIndex == index;
    final primary = theme.colorScheme.primary;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.38);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icon pill ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: isDark ? 0.18 : 0.11)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: isDark ? 0.28 : 0.14),
                        blurRadius: 14,
                        spreadRadius: -2,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) {
                final curved = CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOutBack,
                );
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.65, end: 1.0).animate(curved),
                  child: FadeTransition(opacity: anim, child: child),
                );
              },
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                key: ValueKey(isSelected),
                size: 23,
                color: isSelected ? primary : inactiveColor,
              ),
            ),
          ),

          // ── Label ─────────────────────────────────────────────────────
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? primary : inactiveColor,
              letterSpacing: isSelected ? 0.1 : 0,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),

          // ── Active dot ────────────────────────────────────────────────
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: isSelected ? 5 : 0,
            height: isSelected ? 5 : 0,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notch clipper ─────────────────────────────────────────────────────────────
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchRadius = 34.0;
    final center = size.width / 2;
    final path = Path();

    path.lineTo(center - notchRadius - 12, 0);
    path.quadraticBezierTo(center - notchRadius, 0, center - notchRadius, 12);
    path.arcToPoint(
      Offset(center + notchRadius, 12),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      center + notchRadius,
      0,
      center + notchRadius + 12,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

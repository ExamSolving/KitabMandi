import 'package:flutter/material.dart';
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
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _scaleAnim = Tween(begin: 1.0, end: 0.9).animate(_controller);
  }

  void _onTapSell() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onCenterTap();
  }

  Color _navBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 95,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ///  NAV BAR CONTAINER
          ClipPath(
            clipper: _NavBarClipper(),
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _navBackground(context),

                /// ✨ PREMIUM SHADOW SYSTEM
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.35 : 0.08,
                    ),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],

                /// 🧱 SUBTLE BORDER (LIGHT MODE ONLY)
                border: Border.all(color: _borderColor(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, 'Home', 0, context),
                  _navItem(Icons.chat_bubble_outline, 'Chat', 1, context),

                  const SizedBox(width: 60),

                  _navItem(Icons.inventory_2_outlined, 'My Ads', 2, context),
                  _navItem(Icons.person, 'Profile', 3, context),
                ],
              ),
            ),
          ),

          /// 🔥 FLOATING SELL BUTTON
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: _onTapSell,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    /// ✨ PREMIUM GRADIENT (SOFT, NOT HARSH)
                    color: AppColors.primaryDark,

                    ///  SHADOW DEPTH
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.35),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///  NAV ITEM (IMPROVED PREMIUM STATE)
  Widget _navItem(
    IconData icon,
    String label,
    int index,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✂️ NOTCH CLIPPER (UNCHANGED BUT CLEAN)
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    const notchRadius = 35.0;
    final center = size.width / 2;

    path.lineTo(center - notchRadius - 10, 0);

    path.quadraticBezierTo(center - notchRadius, 0, center - notchRadius, 10);

    path.arcToPoint(
      Offset(center + notchRadius, 10),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      center + notchRadius,
      0,
      center + notchRadius + 10,
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

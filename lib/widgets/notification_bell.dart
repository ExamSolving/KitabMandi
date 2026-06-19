import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/notification/controller/notification_controller.dart';
import 'package:kitab_mandi/features/notification/view/notification_view.dart';

/// Adaptive notification bell — two distinct visual modes:
///
/// • Dark / green app bar  → white glassmorphism circle + white icon
/// • Light / white app bar → no container, just a primary-coloured icon
///
/// Detects the context automatically via [IconTheme], so no parameters needed.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    // AppBar injects the correct foreground colour into IconTheme based on its
    // own background luminance (or an explicit foregroundColor).
    final iconColor = IconTheme.of(context).color ?? Colors.white;

    // luminance ≈ 1.0 for white, ≈ 0 for black.
    // > 0.3  →  the icon is light/white  →  we're on a dark or coloured bar.
    // ≤ 0.3  →  the icon is dark          →  we're on a light bar.
    final isOnDarkBar = iconColor.computeLuminance() > 0.3;

    return Obx(() {
      final count = ctrl.unreadCount;
      final bellIcon = count > 0
          ? Icons.notifications_rounded
          : Icons.notifications_none_rounded;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(() => NotificationView());
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Icon container ───────────────────────────────────────────
              if (isOnDarkBar)
                // Glass pill — premium look on green / dark app bars
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: count > 0 ? 0.25 : 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.32),
                      width: 1,
                    ),
                    boxShadow: count > 0
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.12),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(bellIcon, size: 21, color: Colors.white),
                )
              else
                // Bare icon — clean look on white / light app bars
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(bellIcon, size: 23, color: iconColor),
                ),

              // ── Badge ────────────────────────────────────────────────────
              if (count > 0)
                Positioned(
                  top: isOnDarkBar ? -3 : -1,
                  right: isOnDarkBar ? -3 : -1,
                  child: Container(
                    height: 18,
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4E6A), Color(0xFFE53935)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        // Dark bar: match app-bar shade to look inset.
                        // Light bar: white border separates badge from bg.
                        color: isOnDarkBar
                            ? const Color(0xFF14391A)
                            : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFFF4E6A).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

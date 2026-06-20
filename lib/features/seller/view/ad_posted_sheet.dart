import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

/// Shows the post-listing celebration bottom sheet.
/// Must be called after [Get.offAllNamed] so the dashboard is the active route.
void showAdPostedSheet({required bool isFirstAd}) {
  final ctx = Get.overlayContext;
  if (ctx == null) return;
  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _AdPostedSheet(isFirstAd: isFirstAd),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _AdPostedSheet extends StatefulWidget {
  final bool isFirstAd;
  const _AdPostedSheet({required this.isFirstAd});

  @override
  State<_AdPostedSheet> createState() => _AdPostedSheetState();
}

class _AdPostedSheetState extends State<_AdPostedSheet>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final AnimationController _burstCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _badgeCtrl;

  // ── Animations ───────────────────────────────────────────────────────────────
  late final Animation<double> _iconScale;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _burstProgress;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;
  late final Animation<double> _badgeScale;

  // ── Confetti data ─────────────────────────────────────────────────────────
  static const _colors = [
    Color(0xFF2E7D32), Color(0xFF66BB6A),
    Color(0xFFFF9800), Color(0xFFFFC107),
    Color(0xFF1976D2), Color(0xFF42A5F5),
    Color(0xFFE91E63), Color(0xFFAB47BC),
  ];

  late final List<_Particle> _particles = List.generate(16, (i) {
    final angle = (i / 16) * 2 * pi - pi / 2;
    return _Particle(
      angle: angle,
      distance: 58.0 + (i % 4) * 14.0,
      color: _colors[i % _colors.length],
      size: 6.0 + (i % 3) * 2.5,
      isCircle: i % 3 != 0,
    );
  });

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    if (widget.isFirstAd) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) _badgeCtrl.forward();
      });
    }

    _iconScale = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.35, 0.85)),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 0.95, curve: Curves.easeOut),
      ),
    );

    _burstProgress = CurvedAnimation(
      parent: _burstCtrl,
      curve: Curves.easeOut,
    );

    _pulseScale = Tween<double>(begin: 0.82, end: 1.55).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.38, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeIn),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeCtrl, curve: Curves.elasticOut),
    );

    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _burstCtrl.dispose();
    _pulseCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1D23);
    final subColor = isDark ? Colors.white60 : const Color(0xFF666666);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).padding.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 36),

          // ── Animated icon ────────────────────────────────────────────────
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring 1
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _pulseOpacity.value,
                    child: Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: 98,
                        height: 98,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pulse ring 2 (offset phase)
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) {
                    final phase = (_pulseCtrl.value + 0.45) % 1.0;
                    return Opacity(
                      opacity: (0.3 * (1 - phase)).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.82 + phase * 0.73,
                        child: Container(
                          width: 98,
                          height: 98,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.55),
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Burst particles
                AnimatedBuilder(
                  animation: _burstProgress,
                  builder: (_, _) {
                    final p = _burstProgress.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: _particles.map((pt) {
                        final dist = pt.distance * p;
                        final opacity = (1.0 - p * p).clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(cos(pt.angle) * dist, sin(pt.angle) * dist),
                          child: Opacity(
                            opacity: opacity,
                            child: Transform.rotate(
                              angle: pt.angle + p * pi * 1.2,
                              child: Container(
                                width: pt.size,
                                height: pt.isCircle ? pt.size : pt.size * 0.55,
                                decoration: BoxDecoration(
                                  color: pt.color,
                                  shape: pt.isCircle
                                      ? BoxShape.circle
                                      : BoxShape.rectangle,
                                  borderRadius:
                                      pt.isCircle ? null : BorderRadius.circular(1.5),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                // Main checkmark circle
                AnimatedBuilder(
                  animation: _iconScale,
                  builder: (_, _) => Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.42),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ── Title + subtitle ─────────────────────────────────────────────
          FadeTransition(
            opacity: _contentOpacity,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                children: [
                  Text(
                    widget.isFirstAd
                        ? 'first_ad_live'.tr
                        : 'ad_is_live'.tr,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isFirstAd
                        ? 'first_ad_subtitle'.tr
                        : 'ad_live_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: subColor,
                      height: 1.65,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ── First-ad achievement badge ───────────────────────────────────
          if (widget.isFirstAd) ...[
            const SizedBox(height: 22),
            AnimatedBuilder(
              animation: _badgeScale,
              builder: (_, _) => Transform.scale(
                scale: _badgeScale.value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'achievement_unlocked'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'first_seller'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // ── CTA buttons ─────────────────────────────────────────────────
          FadeTransition(
            opacity: _contentOpacity,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.myAds);
                    },
                    icon: const Icon(Icons.store_rounded, size: 19),
                    label: Text(
                      'view_my_ads'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: Get.back,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      foregroundColor: subColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: Text(
                      'explore_home'.tr,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confetti particle data ───────────────────────────────────────────────────

class _Particle {
  final double angle;
  final double distance;
  final Color color;
  final double size;
  final bool isCircle;

  const _Particle({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
    required this.isCircle,
  });
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';

class EmailVerificationView extends StatefulWidget {
  final String email;
  const EmailVerificationView({super.key, required this.email});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AuthController _ctrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _iconCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AuthController>();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _iconScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addObserver(this);
    _ctrl.startVerificationPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User switched back from their email client — check immediately instead
    // of waiting for the next 3-second poll tick.
    if (state == AppLifecycleState.resumed) {
      _ctrl.checkVerifiedOnResume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.stopVerificationPolling();
    _pulseCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // ── Animated email icon ──────────────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulseCtrl, _iconCtrl]),
                    builder: (_, _) => Opacity(
                      opacity: _iconOpacity.value,
                      child: Transform.scale(
                        scale: _iconScale.value * _pulseAnim.value,
                        child: _EmailIconBadge(isDark: isDark),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Heading ──────────────────────────────────────────────
                Text(
                  'verify_your_email'.tr,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 14),

                // ── Sub-heading ──────────────────────────────────────────
                Text(
                  'verify_email_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: theme.hintColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // ── Email pill ───────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Info card ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoStep(
                        number: 1,
                        text: 'verify_step_1'.tr,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _InfoStep(
                        number: 2,
                        text: 'verify_step_2'.tr,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _InfoStep(
                        number: 3,
                        text: 'verify_step_3'.tr,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Auto-checking indicator ──────────────────────────────
                Obx(
                  () => _ctrl.isCheckingVerification.value
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'verify_checking'.tr,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Resend button ────────────────────────────────────────
                Obx(() {
                  final cooldown = _ctrl.resendCooldown.value;
                  final canResend = cooldown == 0;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: canResend
                          ? _ctrl.resendVerificationEmail
                          : null,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        canResend
                            ? 'resend_email'.tr
                            : '${cooldown}s — ${'resend_in'.tr}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        disabledForegroundColor: Colors.white70,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),

                // ── Wrong email — go back ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _ctrl.cancelVerification(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      foregroundColor: theme.hintColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Text(
                      'wrong_email_go_back'.tr,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Spam note ────────────────────────────────────────────
                Text(
                  'verify_spam_note'.tr,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.hintColor.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated email icon badge ─────────────────────────────────────────────────
class _EmailIconBadge extends StatelessWidget {
  final bool isDark;
  const _EmailIconBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.06),
          ),
        ),
        // Middle ring
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        // Icon circle
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_unread_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        // Top-right checkmark badge
        Positioned(
          top: 18,
          right: 18,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Numbered instruction step ─────────────────────────────────────────────────
class _InfoStep extends StatelessWidget {
  final int number;
  final String text;
  final bool isDark;

  const _InfoStep({
    required this.number,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

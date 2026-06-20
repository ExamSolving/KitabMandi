import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/language_controller.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  final AuthController _ctrl = Get.find<AuthController>();
  final LanguageController _langCtrl = Get.find<LanguageController>();

  // Lives in State so it's created/destroyed with the widget, not the permanent controller.
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ─────────────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;

  // ── Animations ───────────────────────────────────────────────────────────────
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlideY;
  late final Animation<double> _badgeFade;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _cardTranslate;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _logoOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.48, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.62, curve: Curves.elasticOut),
      ),
    );

    _logoSlideY = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.05, 0.52, curve: Curves.easeOutCubic),
      ),
    );

    _badgeFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.42, 0.88, curve: Curves.easeOut),
    );

    _cardOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.26, 0.72, curve: Curves.easeOut),
    );

    _cardTranslate = Tween<double>(begin: 88.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.20, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _floatOffset = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF12151C) : Colors.white;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          isDark ? const Color(0xFF090D0A) : AppColors.primaryDark,
      body: Stack(
        children: [
          // ── Background gradient ─────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0B1A0D), const Color(0xFF060C07)]
                      : [
                          const Color(0xFF0D3B12),
                          AppColors.primary,
                          const Color(0xFF255C2A),
                        ],
                  stops: isDark
                      ? const [0.0, 1.0]
                      : const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Decorative orbs ────────────────────────────────────────────────
          const Positioned(top: -90, right: -65, child: _Orb(230, 0.055)),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.08,
            left: -75,
            child: const _Orb(175, 0.038),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.23,
            right: 28,
            child: const _Orb(60, 0.07),
          ),

          // ── Content ─────────────────────────────────────────────────────────
          Column(
            children: [
              // Logo hero
              Container(
                constraints: const BoxConstraints(
                  minHeight: 164,
                  maxHeight: 290,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      // Language switcher
                      Positioned(
                        top: 8,
                        right: 16,
                        child: _LanguageSwitcher(langCtrl: _langCtrl),
                      ),
                      // Logo + branding (animated)
                      Center(
                        child: AnimatedBuilder(
                          animation:
                              Listenable.merge([_entryCtrl, _floatCtrl]),
                          builder: (_, _) => Opacity(
                            opacity: _logoOpacity.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                _logoSlideY.value + _floatOffset.value,
                              ),
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Glow ring
                                    _LogoRing(),
                                    const SizedBox(height: 18),
                                    Text(
                                      'app_name'.tr,
                                      style: const TextStyle(
                                        fontSize: 29,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Opacity(
                                      opacity:
                                          _badgeFade.value.clamp(0.0, 1.0),
                                      child: const _TaglinePill(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form card (animated slide-up)
              Expanded(
                child: AnimatedBuilder(
                  animation: _entryCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _cardOpacity.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, _cardTranslate.value),
                      child: child,
                    ),
                  ),
                  child: _FormCard(
                    ctrl: _ctrl,
                    isDark: isDark,
                    cardBg: cardBg,
                    theme: theme,
                    formKey: _formKey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo ring with glow
// ─────────────────────────────────────────────────────────────────────────────

class _LogoRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.35),
            blurRadius: 42,
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(17),
      child: Image.asset('assets/splash.png'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tagline pill badge
// ─────────────────────────────────────────────────────────────────────────────

class _TaglinePill extends StatelessWidget {
  const _TaglinePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Text(
        'app_tagline'.tr,
        style: TextStyle(
          fontSize: 11.5,
          color: Colors.white.withValues(alpha: 0.92),
          letterSpacing: 0.9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative circle orb
// ─────────────────────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double size;
  final double opacity;
  const _Orb(this.size, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form card — rounded top, slides up over the gradient
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final AuthController ctrl;
  final bool isDark;
  final Color cardBg;
  final ThemeData theme;
  final GlobalKey<FormState> formKey;

  const _FormCard({
    required this.ctrl,
    required this.isDark,
    required this.cardBg,
    required this.theme,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Obx(
        () => SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            bottomInset + 28,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.14)
                          : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Title + subtitle ────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(ctrl.isLogin.value),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.isLogin.value
                            ? 'auth_welcome_back'.tr
                            : 'auth_create_account'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ctrl.isLogin.value
                            ? 'auth_login_subtitle'.tr
                            : 'auth_signup_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : const Color(0xFF6B7280),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Signup-only fields ──────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  child: ctrl.isLogin.value
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            _AuthField(
                              controller: ctrl.nameController,
                              label: 'label_full_name'.tr,
                              icon: Icons.person_outline_rounded,
                              validator: ctrl.validateName,
                              textInputAction: TextInputAction.next,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                            _AuthField(
                              controller: ctrl.phoneController,
                              label: 'label_phone'.tr,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: ctrl.validatePhone,
                              textInputAction: TextInputAction.next,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                ),

                // ── Email ───────────────────────────────────────────────────
                _AuthField(
                  controller: ctrl.emailController,
                  label: 'label_email'.tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: ctrl.validateEmail,
                  enabled: ctrl.isLogin.value || !ctrl.isGoogleUser.value,
                  readOnly: ctrl.isGoogleUser.value,
                  textInputAction: TextInputAction.next,
                  isDark: isDark,
                ),

                const SizedBox(height: 14),

                // ── Password ────────────────────────────────────────────────
                if (!ctrl.isGoogleUser.value)
                  Obx(
                    () => _AuthField(
                      controller: ctrl.passwordController,
                      label: 'label_password'.tr,
                      icon: Icons.lock_outline_rounded,
                      obscureText: ctrl.obscurePassword.value,
                      validator: ctrl.validatePassword,
                      textInputAction: TextInputAction.done,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          ctrl.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 19,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                        ),
                        onPressed: ctrl.togglePassword,
                      ),
                    ),
                  ),

                // ── Forgot password ─────────────────────────────────────────
                if (ctrl.isLogin.value && !ctrl.isGoogleUser.value)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ctrl.forgotEmailController.text =
                            ctrl.emailController.text.trim();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _ForgotPasswordSheet(
                            ctrl: ctrl,
                            isDark: isDark,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 8,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      child: Text(
                        'forgot_password'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),

                // ── Primary CTA ─────────────────────────────────────────────
                AppButton(
                  text: ctrl.isLogin.value
                      ? 'login'.tr
                      : ctrl.isGoogleUser.value
                          ? 'continue_btn'.tr
                          : 'signup'.tr,
                  isLoading: ctrl.isLoading.value,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (formKey.currentState!.validate()) {
                      ctrl.submit();
                    }
                  },
                ),

                const SizedBox(height: 22),

                // ── Divider ─────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.09)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'or'.tr,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.32)
                              : Colors.black.withValues(alpha: 0.3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.09)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Google sign-in ──────────────────────────────────────────
                _GoogleButton(
                  onTap: ctrl.signInWithGoogle,
                  isDark: isDark,
                ),

                const SizedBox(height: 22),

                // ── Toggle ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ctrl.isLogin.value
                          ? 'dont_have_account'.tr
                          : 'already_have_account'.tr,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.48)
                            : const Color(0xFF6B7280),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ctrl.toggleMode();
                      },
                      child: Text(
                        ctrl.isLogin.value ? 'signup'.tr : 'login'.tr,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Terms ───────────────────────────────────────────────────
                Center(
                  child: Text(
                    'terms_agreement'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.28)
                          : Colors.black.withValues(alpha: 0.25),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cleaned-up text field — icon left, floating label, no divider
// ─────────────────────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final bool isDark;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: label,
      label: label,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      textInputAction: textInputAction,
      suffixIcon: suffixIcon,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, size: 19),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google sign-in button with press-scale micro-interaction
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _GoogleButton({required this.onTap, required this.isDark});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark
        ? const Color(0xFF1C2028)
        : const Color(0xFFF8F9FA);
    final border = widget.isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);
    final textColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFF1F2937);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 52,
          decoration: BoxDecoration(
            color: _pressed
                ? (widget.isDark
                    ? const Color(0xFF22262F)
                    : const Color(0xFFF1F3F5))
                : bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isDark ? 0.22 : 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/google.png', height: 21),
              const SizedBox(width: 12),
              Text(
                'continue_with_google'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Forgot password bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ForgotPasswordSheet extends StatefulWidget {
  final AuthController ctrl;
  final bool isDark;

  const _ForgotPasswordSheet({required this.ctrl, required this.isDark});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward();
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF12151C) : Colors.white;
    final hintColor = isDark ? Colors.white38 : Colors.black26;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 40,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 28),

          // Animated lock icon
          AnimatedBuilder(
            animation: _iconScale,
            builder: (_, _) => Transform.scale(
              scale: _iconScale.value,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.38),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'reset_password_title'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'reset_password_subtitle'.tr,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF6B7280),
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 26),

          // Email field
          _AuthField(
            controller: widget.ctrl.forgotEmailController,
            label: 'label_email'.tr,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Send button
          Obx(
            () => AppButton(
              text: 'send_reset_link'.tr,
              isLoading: widget.ctrl.isLoading.value,
              onPressed: widget.ctrl.forgotPassword,
            ),
          ),

          const SizedBox(height: 10),

          // Cancel
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: Get.back,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: hintColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language switcher (unchanged logic, refined style)
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageSwitcher extends StatelessWidget {
  final LanguageController langCtrl;
  const _LanguageSwitcher({required this.langCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangBtn(
            label: 'EN',
            selected: langCtrl.isEnglish,
            onTap: () => langCtrl.changeLanguage('en'),
          ),
          const SizedBox(width: 3),
          _LangBtn(
            label: 'हिं',
            selected: langCtrl.isHindi,
            onTap: () => langCtrl.changeLanguage('hi'),
          ),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}

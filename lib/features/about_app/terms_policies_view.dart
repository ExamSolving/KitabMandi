import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';

class TermsPoliciesView extends StatelessWidget {
  const TermsPoliciesView({super.key});

  static const _sections = [
    (
      icon: Icons.handshake_outlined,
      title: 'User Agreement',
      content:
          'By using KitabMandi you agree to use the platform responsibly and in good faith. '
          'Users must be 13 years or older to create an account. '
          'You are responsible for all activity under your account. '
          'KitabMandi reserves the right to terminate accounts that violate these terms.',
    ),
    (
      icon: Icons.storefront_outlined,
      title: 'Buying & Selling',
      content:
          'KitabMandi provides a peer-to-peer marketplace connecting buyers and sellers. '
          'We are not responsible for the accuracy of listings, product quality, or the '
          'outcome of any transaction. Users must not list illegal, counterfeit, or '
          'misleading items. KitabMandi does not process payments — all transactions '
          'are between users directly.',
    ),
    (
      icon: Icons.chat_outlined,
      title: 'Chat & Communication',
      content:
          'The in-app chat is strictly for discussing listings and arranging handovers. '
          'Abusive language, harassment, spam, or sharing of personal financial '
          'information is strictly prohibited. KitabMandi reserves the right to review '
          'reported conversations to enforce community safety.',
    ),
    (
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy Policy',
      content:
          'We collect your name, email, phone number, and approximate location to '
          'operate the app. We do not sell your personal data to third parties. '
          'Location data is used solely to display nearby listings. '
          'You may request deletion of your account and data by contacting '
          'support@kitabmandi.com at any time.',
    ),
    (
      icon: Icons.shield_outlined,
      title: 'Account Security',
      content:
          'You are solely responsible for keeping your login credentials confidential. '
          'Never share your password with anyone. Report suspicious activity immediately '
          'to our support team. KitabMandi will never ask for your password via chat '
          'or email. Enable secure authentication where available.',
    ),
    (
      icon: Icons.update_rounded,
      title: 'Policy Updates',
      content:
          'We may revise these terms at any time without prior notice. Material changes '
          'will be communicated via in-app notification or registered email. '
          'Continued use of KitabMandi after changes are published constitutes your '
          'acceptance of the updated terms. Review this page periodically.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: const Text(
              'Terms & Policies',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _TermsHero(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LastUpdatedBadge(isDark: isDark, theme: theme),
                  const SizedBox(height: 20),
                  ...List.generate(_sections.length, (i) {
                    final s = _sections[i];
                    return _PolicySection(
                      number: i + 1,
                      icon: s.icon,
                      title: s.title,
                      content: s.content,
                      isDark: isDark,
                      theme: theme,
                    );
                  }),
                  const SizedBox(height: 10),
                  _TermsFooter(isDark: isDark, theme: theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _TermsHero extends StatelessWidget {
  const _TermsHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D3B12),
                Color(0xFF1B5E20),
                Color(0xFF2E7D32),
              ],
            ),
          ),
        ),
        const CustomPaint(painter: _TermsBubblePainter()),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5),
                ),
                child: const Icon(Icons.gavel_rounded,
                    size: 34, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Terms & Policies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please read carefully before using KitabMandi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermsBubblePainter extends CustomPainter {
  const _TermsBubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.2), 80, p1);
    canvas.drawCircle(
        Offset(size.width * 0.05, size.height * 0.8), 60, p1);
    final p2 = Paint()..color = Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 1.2), 120, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Last updated badge ────────────────────────────────────────────────────────

class _LastUpdatedBadge extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  const _LastUpdatedBadge({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.primary),
              const SizedBox(width: 7),
              const Text(
                'Last updated: June 2026',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.amber.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 13,
                  color: Colors.amber.shade700),
              const SizedBox(width: 6),
              Text(
                'Tap to expand',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Policy Section (expandable) ───────────────────────────────────────────────

class _PolicySection extends StatefulWidget {
  final int number;
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;
  final ThemeData theme;

  const _PolicySection({
    required this.number,
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_PolicySection> createState() => _PolicySectionState();
}

class _PolicySectionState extends State<_PolicySection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1A1D23) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: widget.isDark
            ? []
            : [
                BoxShadow(
                  color: _expanded
                      ? AppColors.primary.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Number badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _expanded
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.number}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _expanded
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Section icon
                  Icon(
                    widget.icon,
                    size: 20,
                    color: _expanded
                        ? AppColors.primary
                        : widget.theme.hintColor,
                  ),
                  const SizedBox(width: 10),
                  // Title
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _expanded
                            ? AppColors.primary
                            : widget.theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  // Chevron
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: widget.theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _expanded
                ? FadeTransition(
                    opacity: _fade,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            height: 1,
                            color:
                                AppColors.primary.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.content,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.68,
                              color: widget.theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _TermsFooter extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  const _TermsFooter({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined,
                size: 26, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            'These policies govern your use of KitabMandi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'By using the app you accept all terms listed above.\n'
            '© 2026 KitabMandi • All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: theme.hintColor, height: 1.65),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/help_center/controller/help_support_controller.dart';
import 'package:kitab_mandi/features/help_center/view/raise_ticket_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportView extends StatelessWidget {
  HelpSupportView({super.key});

  final controller = Get.find<HelpSupportController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: bg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _HelpShimmer(isDark: isDark);
        }
        return CustomScrollView(
          slivers: [
            // ── Hero App Bar ────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
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
              title: Text(
                'help_support_title'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              flexibleSpace: const FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _HelpHero(),
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Us
                    _SectionLabel(label: 'contact_us'.tr),
                    const SizedBox(height: 12),
                    _ContactSection(isDark: isDark, theme: theme),

                    const SizedBox(height: 28),

                    // FAQ
                    _SectionLabel(label: 'faq'.tr),
                    const SizedBox(height: 12),
                    _FaqSection(
                      faqs: controller.faqs,
                      isDark: isDark,
                      theme: theme,
                    ),

                    const SizedBox(height: 28),

                    // Raise Ticket CTA
                    _RaiseTicketBanner(isDark: isDark),

                    const SizedBox(height: 28),

                    // My Tickets
                    _SectionLabel(label: 'my_tickets'.tr),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.userTickets.isEmpty) {
                        return _EmptyTickets(isDark: isDark, theme: theme);
                      }
                      return Column(
                        children: controller.userTickets
                            .map((t) => _TicketCard(
                                  ticket: t,
                                  isDark: isDark,
                                  theme: theme,
                                ))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HelpHero extends StatelessWidget {
  const _HelpHero();

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
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
            ),
          ),
        ),
        const CustomPaint(painter: _HeroBubbles()),
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
                      color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                ),
                child: const Icon(Icons.support_agent_rounded,
                    size: 34, color: Colors.white),
              ),
              const SizedBox(height: 14),
              const Text(
                'How can we help you?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We\'re here to help, 7 days a week',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
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

class _HeroBubbles extends CustomPainter {
  const _HeroBubbles();

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.18), 80, p1);
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.78), 60, p1);
    final p2 = Paint()..color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 1.15), 100, p2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.12), 45, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ── Contact section ───────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  const _ContactSection({required this.isDark, required this.theme});

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final rows = [
      (
        icon: Icons.chat_rounded,
        color: const Color(0xFF25D366),
        label: 'whatsapp_support'.tr,
        value: '+91 6306937005',
        url: 'https://wa.me/916306937005',
        divider: true,
      ),
      (
        icon: Icons.email_outlined,
        color: AppColors.primaryLight,
        label: 'email_support'.tr,
        value: 'examsolvingofficial@gmail.com',
        url: 'mailto:examsolvingofficial@gmail.com',
        divider: true,
      ),
      (
        icon: Icons.call_rounded,
        color: AppColors.secondary,
        label: 'call_support'.tr,
        value: '+91 6306937005',
        url: 'tel:+916306937005',
        divider: false,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: rows.map((r) {
          return Column(
            children: [
              InkWell(
                onTap: () => _launch(r.url),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: r.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(r.icon, size: 19, color: r.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.value,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: theme.hintColor),
                    ],
                  ),
                ),
              ),
              if (r.divider)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.06),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── FAQ section ───────────────────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  final RxList<Map<String, dynamic>> faqs;
  final bool isDark;
  final ThemeData theme;

  const _FaqSection({
    required this.faqs,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (faqs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('No FAQs available',
              style: TextStyle(color: theme.hintColor)),
        ),
      );
    }
    return Column(
      children: faqs
          .asMap()
          .entries
          .map((e) => _FaqTile(
                index: e.key + 1,
                question: e.value['question'] ?? '',
                answer: e.value['answer'] ?? '',
                isDark: isDark,
                theme: theme,
              ))
          .toList(),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final int index;
  final String question;
  final String answer;
  final bool isDark;
  final ThemeData theme;

  const _FaqTile({
    required this.index,
    required this.question,
    required this.answer,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1A1D23) : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _open
              ? AppColors.primary.withValues(alpha: 0.28)
              : widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: widget.isDark
            ? []
            : [
                BoxShadow(
                  color: _open
                      ? AppColors.primary.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _open
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color:
                              _open ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _open
                            ? AppColors.primary
                            : widget.theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
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
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _open
                ? FadeTransition(
                    opacity: _fade,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                              height: 1,
                              color: AppColors.primary
                                  .withValues(alpha: 0.14)),
                          const SizedBox(height: 12),
                          Text(
                            widget.answer,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.65,
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

// ── Raise ticket banner ───────────────────────────────────────────────────────

class _RaiseTicketBanner extends StatelessWidget {
  final bool isDark;
  const _RaiseTicketBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Raise a ticket and our team will respond within 24 hours.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Get.to(() => RaiseTicketView());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Raise a Ticket',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── Ticket card ───────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isDark;
  final ThemeData theme;

  const _TicketCard({
    required this.ticket,
    required this.isDark,
    required this.theme,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'resolved':
        return const Color(0xFF2E7D32);
      case 'in_progress':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFB71C1C);
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.timelapse_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] as String? ?? 'open';
    final sc = _statusColor(status);
    final bg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon(status), size: 20, color: sc),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['title'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket['category'] as String? ?? '',
                  style: TextStyle(
                      fontSize: 12, color: theme.hintColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sc.withValues(alpha: 0.25)),
            ),
            child: Text(
              status.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                color: sc,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty tickets ─────────────────────────────────────────────────────────────

class _EmptyTickets extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  const _EmptyTickets({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined,
                size: 28, color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          Text(
            'no_tickets_yet'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your support tickets will appear here',
            style:
                TextStyle(fontSize: 12, color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _HelpShimmer extends StatelessWidget {
  final bool isDark;
  const _HelpShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF1E2430) : Colors.grey.shade300;
    final hi = isDark ? const Color(0xFF2A3140) : Colors.grey.shade100;
    final fill = isDark ? const Color(0xFF171B22) : Colors.white;
    final card = isDark ? const Color(0xFF1A1D23) : Colors.white;

    Widget box(double w, double h, {double r = 8}) => Container(
          width: w,
          height: h,
          decoration:
              BoxDecoration(color: fill, borderRadius: BorderRadius.circular(r)),
        );

    // Section label: 4px green bar + shimmer text line
    Widget label() => Row(
          children: [
            Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    color: fill, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 9),
            box(88, 11, r: 4),
          ],
        );

    // One contact row: icon square + 2 text lines + arrow
    Widget contactRow({bool divider = true}) => Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  box(38, 38, r: 11),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        box(78, 11, r: 4),
                        const SizedBox(height: 5),
                        box(148, 14, r: 5),
                      ],
                    ),
                  ),
                  box(12, 12, r: 3),
                ],
              ),
            ),
            if (divider)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.06),
              ),
          ],
        );

    // One collapsed FAQ tile: circle number + text line + arrow
    Widget faqTile() => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration:
              BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              box(30, 30, r: 15),
              const SizedBox(width: 12),
              Expanded(child: box(0, 14, r: 5)),
              const SizedBox(width: 12),
              box(20, 20, r: 5),
            ],
          ),
        );

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // ── Real hero AppBar (no shimmer — always green) ──────────────────
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.primary,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
          title: const Text(
            'Help & Support',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
          ),
          flexibleSpace: const FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: _HelpHero(),
          ),
        ),

        // ── Shimmer body — mirrors exact section layout ────────────────────
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: base,
            highlightColor: hi,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Us section
                  label(),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        contactRow(),
                        contactRow(),
                        contactRow(divider: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // FAQ section
                  label(),
                  const SizedBox(height: 12),
                  faqTile(),
                  faqTile(),
                  faqTile(),
                  faqTile(),
                  faqTile(),

                  const SizedBox(height: 28),

                  // Raise Ticket Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box(140, 17, r: 6),
                              const SizedBox(height: 8),
                              box(220, 12, r: 4),
                              const SizedBox(height: 5),
                              box(180, 12, r: 4),
                              const SizedBox(height: 14),
                              box(110, 36, r: 10),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        box(56, 56, r: 28),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // My Tickets section
                  label(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        box(40, 40, r: 12),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box(160, 14, r: 5),
                              const SizedBox(height: 6),
                              box(100, 11, r: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        box(60, 24, r: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

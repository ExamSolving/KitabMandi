import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/help_center/controller/help_support_controller.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class RaiseTicketView extends StatelessWidget {
  RaiseTicketView({super.key});

  final controller = Get.find<HelpSupportController>();

  static Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFB71C1C);
      case 'Medium':
        return const Color(0xFFE65100);
      default:
        return AppColors.primary;
    }
  }

  static IconData _priorityIcon(String p) {
    switch (p) {
      case 'High':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'Medium':
        return Icons.drag_handle_rounded;
      default:
        return Icons.keyboard_double_arrow_down_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
          'Raise a Ticket',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            _HeroBanner(),
            const SizedBox(height: 24),

            // ── Category ────────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.category_outlined,
              title: 'What\'s the issue about?',
            ),
            const SizedBox(height: 12),
            Obx(() => _CategoryGrid(
                  categories: controller.categories,
                  selected: controller.selectedCategory.value,
                  isDark: isDark,
                  cardBg: cardBg,
                  onSelect: (v) => controller.selectedCategory.value = v,
                )),

            const SizedBox(height: 22),

            // ── Priority ─────────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.flag_outlined,
              title: 'Priority',
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
                  children: controller.priorities.map((p) {
                    final sel = controller.selectedPriority.value == p;
                    final color = _priorityColor(p);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.selectedPriority.value = p;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel
                                ? color
                                : color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel
                                  ? color
                                  : color.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _priorityIcon(p),
                                size: 18,
                                color: sel ? Colors.white : color,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),

            const SizedBox(height: 22),

            // ── Title ────────────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.title_rounded,
              title: 'Title',
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: controller.titleCtrl,
              hintText: 'e.g. App crashes when opening chat',
            ),

            const SizedBox(height: 18),

            // ── Description ──────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.description_outlined,
              title: 'Description',
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: controller.descCtrl,
              hintText:
                  'Describe the issue in detail — steps to reproduce, screenshots, what you expected vs what happened...',
              maxLines: 5,
            ),

            const SizedBox(height: 28),

            // ── Submit ───────────────────────────────────────────────────
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          controller.submitTicket();
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Submit Ticket',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 13, color: theme.hintColor),
                  const SizedBox(width: 5),
                  Text(
                    'Typical response time: within 24 hours',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            ),
            child: const Icon(Icons.headset_mic_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tell us what\'s wrong and we\'ll get back to you promptly.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.45,
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

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Category grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final bool isDark;
  final Color cardBg;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.isDark,
    required this.cardBg,
    required this.onSelect,
  });

  static IconData _icon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('bug') || c.contains('crash')) return Icons.bug_report_outlined;
    if (c.contains('login') || c.contains('account')) return Icons.lock_outline_rounded;
    if (c.contains('chat') || c.contains('messag')) return Icons.chat_bubble_outline_rounded;
    if (c.contains('notif')) return Icons.notifications_none_rounded;
    if (c.contains('ui') || c.contains('ux') || c.contains('design')) return Icons.palette_outlined;
    if (c.contains('search') || c.contains('filter')) return Icons.search_rounded;
    if (c.contains('feature') || c.contains('request')) return Icons.lightbulb_outline_rounded;
    return Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        final sel = selected == cat;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(cat);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.primary
                  : cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel
                    ? AppColors.primary
                    : isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  _icon(cat),
                  size: 17,
                  color: sel
                      ? Colors.white
                      : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

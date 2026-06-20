import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/resume/controller/cover_letter_controller.dart';
import 'package:kitab_mandi/features/resume/controller/resume_controller.dart';
import 'package:kitab_mandi/features/resume/model/cover_letter_model.dart';
import 'package:kitab_mandi/features/resume/model/resume_model.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class ResumeView extends StatelessWidget {
  const ResumeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<ResumeController>()
        ? ResumeController.to
        : Get.put(ResumeController());
    final clCtrl = Get.isRegistered<CoverLetterController>()
        ? CoverLetterController.to
        : Get.put(CoverLetterController());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            // ── Hero ──────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _HeroHeader(ctrl: ctrl, clCtrl: clCtrl, isDark: isDark),
            ),

            // ── Feature cards ─────────────────────────────────────────────────
            // Own Obx so clUsage / usage badges update independently.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Obx(() => Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            icon: Icons.description_rounded,
                            title: 'ai_resume_builder'.tr,
                            subtitle: 'ats_optimised_minutes'.tr,
                            badgeLabel: _resumeBadge(ctrl),
                            onTap: () {
                              if (ctrl.usage.value?.canGenerate ?? false) {
                                Get.toNamed(AppRoutes.resumeForm);
                              } else {
                                Get.toNamed(AppRoutes.subscription);
                              }
                            },
                            ctaLabel: (ctrl.usage.value?.canGenerate ?? false)
                                ? 'build_now'.tr
                                : 'upgrade'.tr,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FeatureCard(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            icon: Icons.mail_outline_rounded,
                            title: 'ai_cover_letter'.tr,
                            subtitle: 'personalised_seconds'.tr,
                            badgeLabel: _clBadge(ctrl, clCtrl),
                            onTap: ctrl.resumes.isEmpty
                                ? null
                                : () => Get.toNamed(AppRoutes.coverLetter),
                            ctaLabel: _clCta(ctrl, clCtrl),
                          ),
                        ),
                      ],
                    )),
              ),
            ),

            // ── My Resumes ────────────────────────────────────────────────────
            if (ctrl.resumes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'my_resumes'.tr,
                  count: ctrl.resumes.length,
                  isDark: isDark,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ResumeCard(record: ctrl.resumes[i]),
                  childCount: ctrl.resumes.length,
                ),
              ),
            ],

            // ── My Cover Letters ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (clCtrl.isLoading.value || clCtrl.coverLetters.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'my_cover_letters'.tr,
                      count: clCtrl.coverLetters.length,
                      isDark: isDark,
                    ),
                    ...clCtrl.coverLetters
                        .map((cl) => _CoverLetterCard(record: cl, clCtrl: clCtrl)),
                  ],
                );
              }),
            ),

            // ── Empty state ───────────────────────────────────────────────────
            if (ctrl.resumes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(isDark: isDark),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  String _resumeBadge(ResumeController ctrl) {
    final usage = ctrl.usage.value;
    if (usage == null) return '';
    if (usage.isUnlimited) return 'unlimited_badge'.tr;
    return usage.canGenerate
        ? '${usage.maxCount - usage.usedCount} left'
        : 'limit_reached'.tr;
  }

  String _clBadge(ResumeController ctrl, CoverLetterController clCtrl) {
    if (ctrl.resumes.isEmpty) return 'build_resume_first'.tr;
    final usage = clCtrl.clUsage.value;
    if (usage == null) return '';
    if (!usage.canGenerate) return 'limit_reached'.tr;
    return '${usage.remaining} left';
  }

  String _clCta(ResumeController ctrl, CoverLetterController clCtrl) {
    if (ctrl.resumes.isEmpty) return 'create_now'.tr;
    final usage = clCtrl.clUsage.value;
    if (usage != null && !usage.canGenerate) return 'upgrade'.tr;
    return 'create_now'.tr;
  }
}

// ── Hero header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final ResumeController ctrl;
  final CoverLetterController clCtrl;
  final bool isDark;

  const _HeroHeader({
    required this.ctrl,
    required this.clCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final plan = SubscriptionService.getPlan(ctrl.sub.value);
    final planLabel = SubscriptionService.planLabel(plan);
    final isPro = plan == RazorpayConfig.planProMonthly ||
        plan == RazorpayConfig.planProAnnual;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D3B12), const Color(0xFF0A2E10)]
              : [const Color(0xFF1B5E20), const Color(0xFF0D3B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: title + plan badge
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ai_career_tools'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    // Plan badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPro
                            ? Colors.amber.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPro
                              ? Colors.amber.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPro
                                ? Icons.workspace_premium_rounded
                                : Icons.person_outline_rounded,
                            size: 12,
                            color: isPro ? Colors.amber : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            planLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPro ? Colors.amber : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'build_smarter_land_faster'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 14),
                // Stats row — Obx so cover-letter count and ATS score
                // update the moment data loads or a new item is generated.
                Obx(() {
                  final rCount = ctrl.resumes.length;
                  final clCount = clCtrl.coverLetters.length;
                  final atsScore = rCount > 0
                      ? _computeAts(ctrl.resumes.first.data)
                      : null;
                  final sep = Container(
                      width: 1,
                      height: 14,
                      color: Colors.white.withValues(alpha: 0.2));
                  return Row(
                    children: [
                      _HeroStat(
                        icon: Icons.description_rounded,
                        label:
                            '$rCount Resume${rCount != 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 6),
                      sep,
                      const SizedBox(width: 6),
                      _HeroStat(
                        icon: Icons.mail_rounded,
                        label:
                            '$clCount Cover Letter${clCount != 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 6),
                      sep,
                      const SizedBox(width: 6),
                      _HeroStat(
                        icon: Icons.track_changes_rounded,
                        label: atsScore != null
                            ? 'ATS $atsScore%'
                            : 'ats_score'.tr,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ],
      );
}

// ── Feature card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final VoidCallback? onTap;
  final String ctaLabel;

  const _FeatureCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    required this.onTap,
    required this.ctaLabel,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: disabled ? null : gradient,
          color: disabled ? Colors.grey.shade200 : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: disabled ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: disabled ? Colors.grey : Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: disabled ? Colors.grey : Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: disabled
                    ? Colors.grey.shade400
                    : Colors.white.withValues(alpha: 0.75),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            // Badge or CTA
            if (badgeLabel != null && badgeLabel!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: disabled ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            if (!disabled)
              Row(
                children: [
                  Text(
                    ctaLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: Colors.white),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;

  const _SectionHeader(
      {required this.title, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              )),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ── ATS score helper ──────────────────────────────────────────────────────────

int _computeAts(GeneratedResume r) {
  int score = 40;
  score += (r.keywordsMatched.length * 5).clamp(0, 40);
  if (r.experience.isNotEmpty) score += 15;
  if (r.certifications.isNotEmpty) score += 5;
  return score.clamp(0, 100);
}

Color _atsColor(int score) {
  if (score >= 80) return const Color(0xFF2E7D32);
  if (score >= 65) return const Color(0xFFF57C00);
  return const Color(0xFFD32F2F);
}

String _atsLabel(int score) {
  if (score >= 80) return 'ats_excellent'.tr;
  if (score >= 65) return 'ats_good'.tr;
  return 'ats_fair'.tr;
}

// ── Resume card ───────────────────────────────────────────────────────────────

class _ResumeCard extends StatelessWidget {
  final ResumeRecord record;
  const _ResumeCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final d = record.data;
    final ats = _computeAts(d);
    final atsColor = _atsColor(ats);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.resumePreview, arguments: record),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D23) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doc icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            // Name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.contact.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 3),
                  Text(
                    d.summary.isNotEmpty
                        ? d.summary
                        : d.skills.technical.take(3).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11.5,
                        color: theme.hintColor,
                        height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(
                          label: record.templateId == 'modern'
                              ? 'template_modern'.tr
                              : 'template_classic'.tr),
                      const SizedBox(width: 6),
                      Text(_fmtDate(record.createdAt),
                          style: TextStyle(
                              fontSize: 10.5,
                              color: theme.hintColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // ATS score badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AtsRing(score: ats, color: atsColor),
                const SizedBox(height: 4),
                Text(_atsLabel(ats),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: atsColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ── ATS ring widget ───────────────────────────────────────────────────────────

class _AtsRing extends StatelessWidget {
  final int score;
  final Color color;
  const _AtsRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 3.5,
            backgroundColor:
                color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cover letter card ─────────────────────────────────────────────────────────

class _CoverLetterCard extends StatelessWidget {
  final CoverLetterRecord record;
  final CoverLetterController clCtrl;
  const _CoverLetterCard(
      {required this.record, required this.clCtrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.coverLetter,
          arguments: record),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D23) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mail_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.jobTitle,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(record.companyName,
                      style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF1565C0),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(_fmtDate(record.createdAt),
                      style: TextStyle(
                          fontSize: 10.5,
                          color: theme.hintColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: const Icon(Icons.description_outlined,
              size: 38, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text('no_resumes_yet'.tr,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 6),
        Text(
          'build_first_resume_subtitle'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13, color: theme.hintColor, height: 1.5),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}

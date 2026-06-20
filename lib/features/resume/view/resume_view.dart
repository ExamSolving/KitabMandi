import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/resume/controller/resume_controller.dart';
import 'package:kitab_mandi/features/resume/model/resume_model.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class ResumeView extends StatelessWidget {
  const ResumeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered (from dashboard binding)
    final ctrl = Get.isRegistered<ResumeController>()
        ? ResumeController.to
        : Get.put(ResumeController());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, isDark),
              SliverToBoxAdapter(
                child: _buildUsageCard(context, ctrl, isDark),
              ),
              SliverToBoxAdapter(
                child: _buildBuildButton(context, ctrl, isDark),
              ),
              if (ctrl.resumes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, isDark),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text('Your Resumes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        )),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ResumeCard(record: ctrl.resumes[i]),
                    childCount: ctrl.resumes.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          );
        }),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text('AI Resume Builder',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildUsageCard(
      BuildContext context, ResumeController ctrl, bool isDark) {
    final theme = Theme.of(context);
    final usage = ctrl.usage.value;
    final plan = SubscriptionService.getPlan(ctrl.sub.value);
    final planLabel = SubscriptionService.planLabel(plan);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
              AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(planLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (usage != null)
                    Text(
                      usage.isUnlimited
                          ? 'Unlimited resumes'
                          : usage.limitLabel,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface),
                    ),
                ],
              ),
            ),
            if (plan == RazorpayConfig.planFree ||
                plan == RazorpayConfig.planPlusMonthly ||
                plan == RazorpayConfig.planPlusAnnual)
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.subscription),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Upgrade',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildButton(
      BuildContext context, ResumeController ctrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Obx(() {
        final canGen = ctrl.usage.value?.canGenerate ?? false;
        return GestureDetector(
          onTap: canGen ? () => Get.toNamed(AppRoutes.resumeForm) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              gradient: canGen
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: canGen ? null : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
              boxShadow: canGen
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: canGen ? Colors.white : Colors.grey,
                    size: 18),
                const SizedBox(width: 8),
                Text(
                  canGen ? 'Build My ATS Resume' : 'Limit Reached',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: canGen ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
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
        Text('No resumes yet',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 6),
        Text('Build your first ATS-optimized resume\nwith AI in minutes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: theme.hintColor, height: 1.5)),
        const SizedBox(height: 60),
      ],
    );
  }
}

// ─── Resume history card ───────────────────────────────────────────────────────

class _ResumeCard extends StatelessWidget {
  final ResumeRecord record;
  const _ResumeCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final d = record.data;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.resumePreview, arguments: record),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.contact.name,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(d.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: theme.hintColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _tag(record.templateId == 'modern' ? 'Modern' : 'Classic',
                          theme),
                      const SizedBox(width: 6),
                      Text(
                        _fmtDate(record.createdAt),
                        style: TextStyle(fontSize: 10.5, color: theme.hintColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
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

  Widget _tag(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
}

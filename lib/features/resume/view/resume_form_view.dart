import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/resume/controller/resume_controller.dart';
import 'package:kitab_mandi/features/resume/model/resume_template.dart';
import 'package:kitab_mandi/widgets/kitab_back_button.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ResumeFormView extends StatelessWidget {
  const ResumeFormView({super.key});

  static List<String> get _steps => [
    'step_personal'.tr,
    'step_education'.tr,
    'step_skills'.tr,
    'step_experience'.tr,
    'step_projects'.tr,
    'step_finalize'.tr,
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = ResumeController.to;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const KitabBackButton(),
        title: Obx(() => Text(
              'Step ${ctrl.currentStep.value + 1} of ${_steps.length}: '
              '${_steps[ctrl.currentStep.value]}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Obx(() {
            final progress =
                (ctrl.currentStep.value + 1) / _steps.length;
            return LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
              color: AppColors.primary,
              minHeight: 3,
            );
          }),
        ),
      ),
      body: Obx(() {
        final step = ctrl.currentStep.value;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: _stepWidget(step, ctrl, context, isDark),
          ),
        );
      }),
      bottomNavigationBar: _BottomBar(),
    );
  }

  Widget _stepWidget(
      int step, ResumeController ctrl, BuildContext ctx, bool isDark) {
    switch (step) {
      case 0:
        return _Step1Personal(ctrl: ctrl);
      case 1:
        return _Step2Education(ctrl: ctrl);
      case 2:
        return _Step3Skills(ctrl: ctrl, isDark: isDark);
      case 3:
        return _Step4Experience(ctrl: ctrl, isDark: isDark);
      case 4:
        return _Step5Projects(ctrl: ctrl, isDark: isDark);
      case 5:
        return _Step6Finalize(ctrl: ctrl, isDark: isDark);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = ResumeController.to;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12, width: 0.5),
        ),
      ),
      child: Obx(() {
        final step = ctrl.currentStep.value;
        final isLast = step == ResumeFormView._steps.length - 1;

        return Row(
          children: [
            if (step > 0)
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => ctrl.currentStep.value--,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('back'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                    onPressed: ctrl.isGenerating.value
                        ? null
                        : () {
                            if (!ctrl.validateStep(step)) return;
                            if (isLast) {
                              ctrl.generate();
                            } else {
                              ctrl.currentStep.value++;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: ctrl.isGenerating.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            isLast ? 'generate_resume'.tr : 'continue_btn'.tr,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                  )),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Step 1: Personal Info ────────────────────────────────────────────────────

class _Step1Personal extends StatelessWidget {
  final ResumeController ctrl;
  const _Step1Personal({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.person_rounded,
      title: 'personal_information'.tr,
      subtitle: 'personal_info_subtitle'.tr,
      child: Column(
        children: [
          _Field(ctrl: ctrl.nameCtrl, label: 'Full Name *',
              hint: 'e.g. Aditya Kumar', errorKey: 'name'),
          _Field(ctrl: ctrl.emailCtrl, label: 'Email *',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress, errorKey: 'email'),
          _Field(ctrl: ctrl.phoneCtrl, label: 'Phone *',
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone, errorKey: 'phone'),
          _Field(ctrl: ctrl.locationCtrl, label: 'Location *',
              hint: 'e.g. Bangalore, India', errorKey: 'location'),
          _Field(ctrl: ctrl.linkedinCtrl, label: 'LinkedIn (optional)',
              hint: 'linkedin.com/in/yourname'),
          _Field(ctrl: ctrl.githubCtrl, label: 'GitHub (optional)',
              hint: 'github.com/yourusername'),
        ],
      ),
    );
  }
}

// ─── Step 2: Education ────────────────────────────────────────────────────────

class _Step2Education extends StatelessWidget {
  final ResumeController ctrl;
  const _Step2Education({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.school_rounded,
      title: 'education_label'.tr,
      subtitle: 'education_subtitle'.tr,
      child: Column(
        children: [
          _Field(ctrl: ctrl.degreeCtrl, label: 'Degree / Course *',
              hint: 'e.g. B.Tech Computer Science', errorKey: 'degree'),
          _Field(ctrl: ctrl.institutionCtrl, label: 'College / University *',
              hint: 'e.g. IIT Bombay', errorKey: 'institution'),
          _Field(ctrl: ctrl.yearCtrl, label: 'Graduation Year *',
              hint: 'e.g. 2024',
              keyboardType: TextInputType.number, errorKey: 'year'),
          _Field(ctrl: ctrl.gpaCtrl, label: 'CGPA / Percentage (optional)',
              hint: 'e.g. 8.5 / 85%'),
        ],
      ),
    );
  }
}

// ─── Step 3: Skills ───────────────────────────────────────────────────────────

class _Step3Skills extends StatelessWidget {
  final ResumeController ctrl;
  final bool isDark;
  const _Step3Skills({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.code_rounded,
      title: 'skills_label'.tr,
      subtitle: 'skills_subtitle'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChipInput(
            ctrl: ctrl.techSkillCtrl,
            label: 'Technical Skills *',
            hint: 'e.g. Flutter, Python, SQL …',
            chips: ctrl.techSkills,
            onAdd: ctrl.addTechSkill,
            onRemove: ctrl.removeTechSkill,
            isDark: isDark,
            errorKey: 'techSkills',
          ),
          const SizedBox(height: 20),
          _ChipInput(
            ctrl: ctrl.softSkillCtrl,
            label: 'Soft Skills',
            hint: 'e.g. Leadership, Communication …',
            chips: ctrl.softSkills,
            onAdd: ctrl.addSoftSkill,
            onRemove: ctrl.removeSoftSkill,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: Experience ───────────────────────────────────────────────────────

class _Step4Experience extends StatelessWidget {
  final ResumeController ctrl;
  final bool isDark;
  const _Step4Experience({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.work_rounded,
      title: 'experience_label'.tr,
      subtitle: 'experience_subtitle'.tr,
      child: Obx(() => Column(
            children: [
              ...List.generate(ctrl.experiences.length, (i) {
                final e = ctrl.experiences[i];
                return _EntryCard(
                  index: i,
                  canRemove: ctrl.experiences.length > 1,
                  onRemove: () => ctrl.removeExperience(i),
                  isDark: isDark,
                  children: [
                    _Field(ctrl: e['title']!, label: 'Job Title',
                        hint: 'e.g. Software Intern',
                        errorKey: 'exp_title_$i'),
                    _Field(ctrl: e['company']!, label: 'Company',
                        hint: 'e.g. Infosys'),
                    _Field(ctrl: e['duration']!, label: 'Duration',
                        hint: 'e.g. Jun 2023 – Aug 2023'),
                    _Field(ctrl: e['description']!, label: 'What you did',
                        hint: 'Describe your responsibilities and achievements…',
                        maxLines: 4),
                  ],
                );
              }),
              const SizedBox(height: 8),
              _AddButton(
                label: 'add_another_experience'.tr,
                onTap: ctrl.addExperience,
              ),
            ],
          )),
    );
  }
}

// ─── Step 5: Projects ─────────────────────────────────────────────────────────

class _Step5Projects extends StatelessWidget {
  final ResumeController ctrl;
  final bool isDark;
  const _Step5Projects({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.rocket_launch_rounded,
      title: 'projects_label'.tr,
      subtitle: 'projects_subtitle'.tr,
      child: Obx(() => Column(
            children: [
              ...List.generate(ctrl.projects.length, (i) {
                final p = ctrl.projects[i];
                return _EntryCard(
                  index: i,
                  canRemove: ctrl.projects.length > 1,
                  onRemove: () => ctrl.removeProject(i),
                  isDark: isDark,
                  children: [
                    _Field(ctrl: p['title']!, label: 'Project Title',
                        hint: 'e.g. KitabMandi App',
                        errorKey: 'proj_title_$i'),
                    _Field(ctrl: p['tech']!, label: 'Tech Stack',
                        hint: 'e.g. Flutter, Firebase, Node.js'),
                    _Field(ctrl: p['link']!, label: 'Link (optional)',
                        hint: 'github.com/… or play.google.com/…'),
                    _Field(ctrl: p['description']!, label: 'Description',
                        hint: 'What does it do? What impact did it have?',
                        maxLines: 3),
                  ],
                );
              }),
              const SizedBox(height: 8),
              _AddButton(
                label: 'add_another_project'.tr,
                onTap: ctrl.addProject,
              ),
            ],
          )),
    );
  }
}

// ─── Step 6: Finalize ─────────────────────────────────────────────────────────

class _Step6Finalize extends StatelessWidget {
  final ResumeController ctrl;
  final bool isDark;
  const _Step6Finalize({required this.ctrl, required this.isDark});

  void _showUpgradeSheet(BuildContext context, ResumeTemplate t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: t.tierColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_rounded, color: t.tierColor, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              '${t.name} Template',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'This template is available on the ${t.tierLabel} plan',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/subscription');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.tierColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Upgrade to ${t.tierLabel}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPreview(BuildContext context, String templateId) async {
    final bytes = await ctrl.generatePreview(templateId);
    if (bytes == null) return;
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Text(
                    'template_preview'.tr,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PdfPreview(
                build: (_) => bytes,
                canDebug: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                allowPrinting: false,
                allowSharing: false,
                initialPageFormat: PdfPageFormat.a4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _StepScaffold(
      icon: Icons.auto_awesome_rounded,
      title: 'finalize_generate'.tr,
      subtitle: 'paste_jd_hint'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Template gallery ─────────────────────────────────────────────
          Row(
            children: [
              Text(
                'resume_template'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Obx(() => ctrl.isPreviewLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.preview_rounded, size: 15),
                      label: Text('preview'.tr,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () => _showPreview(
                          context, ctrl.selectedTemplate.value),
                    )),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal scrollable gallery
          SizedBox(
            height: 172,
            child: Obx(() {
              // Read observables at top of Obx scope so GetX tracks them
              final selectedId = ctrl.selectedTemplate.value;
              final sub = ctrl.sub.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 4),
                itemCount: ResumeTemplate.all.length,
                separatorBuilder: (_, i) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final t = ResumeTemplate.all[i];
                  final unlocked = t.isUnlocked(sub);
                  final selected = selectedId == t.id;
                  return _TemplateGalleryCard(
                    template: t,
                    unlocked: unlocked,
                    selected: selected,
                    isDark: isDark,
                    onTap: () => unlocked
                        ? ctrl.selectedTemplate.value = t.id
                        : _showUpgradeSheet(ctx, t),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 20),

          // Certifications
          _ChipInput(
            ctrl: ctrl.certCtrl,
            label: 'certifications_optional'.tr,
            hint: 'certification_hint'.tr,
            chips: ctrl.certs,
            onAdd: ctrl.addCert,
            onRemove: ctrl.removeCert,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // JD
          Text(
            'target_job_desc'.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'paste_jd_hint'.tr,
            style: TextStyle(fontSize: 11.5, color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.jdCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'paste_jd_placeholder'.tr,
              hintStyle: TextStyle(color: theme.hintColor, fontSize: 13),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ai_generate_notice'.tr,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.85),
                      height: 1.4,
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

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: theme.hintColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? errorKey;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.errorKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (errorKey != null) {
      return Obx(() {
        final errorMsg = ResumeController.to.fieldErrors[errorKey!];
        final hasError = errorMsg != null && errorMsg.isNotEmpty;
        return _buildContent(theme, isDark, hasError, errorMsg);
      });
    }
    return _buildContent(theme, isDark, false, null);
  }

  Widget _buildContent(
      ThemeData theme, bool isDark, bool hasError, String? errorMsg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: hasError
                      ? Colors.red.shade600
                      : theme.colorScheme.onSurface)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: errorKey != null
                ? (_) => ResumeController.to.clearFieldError(errorKey!)
                : null,
            style: TextStyle(
                fontSize: 14, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: theme.hintColor, fontSize: 13),
              filled: true,
              fillColor: hasError
                  ? Colors.red.withValues(alpha: 0.06)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: hasError
                    ? BorderSide(color: Colors.red.shade400, width: 1.5)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError ? Colors.red.shade400 : AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 13, color: Colors.red.shade600),
                const SizedBox(width: 4),
                Text(errorMsg!,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final RxList<String> chips;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final bool isDark;
  final String? errorKey;

  const _ChipInput({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.chips,
    required this.onAdd,
    required this.onRemove,
    required this.isDark,
    this.errorKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final resumeCtrl = ResumeController.to;
      final errorMsg =
          errorKey != null ? resumeCtrl.fieldErrors[errorKey!] : null;
      final hasError = errorMsg != null && errorMsg.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: hasError
                      ? Colors.red.shade600
                      : theme.colorScheme.onSurface)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  onSubmitted: onAdd,
                  style: TextStyle(
                      fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        TextStyle(color: theme.hintColor, fontSize: 13),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onAdd(ctrl.text),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          chips.isEmpty
              ? const SizedBox.shrink()
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips
                      .map((s) => _SkillChip(label: s, onDelete: onRemove))
                      .toList(),
                ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 13, color: Colors.red.shade600),
                const SizedBox(width: 4),
                Text(errorMsg,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final void Function(String) onDelete;
  const _SkillChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onDelete(label),
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final bool isDark;
  final List<Widget> children;

  const _EntryCard({
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Entry ${index + 1}',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor)),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.redAccent),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      ),
    );
  }
}

// ─── Template gallery card ────────────────────────────────────────────────────

class _TemplateGalleryCard extends StatelessWidget {
  final ResumeTemplate template;
  final bool unlocked;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TemplateGalleryCard({
    required this.template,
    required this.unlocked,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  Widget _line({double? width, required double h, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      width: width,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildPreview() {
    final c = template.primary;
    final bg = template.accent;
    switch (template.layout) {
      case 'band':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 28,
              color: c,
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _line(width: 52, h: 4, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(height: 3),
                  _line(width: 70, h: 2, color: Colors.white.withValues(alpha: 0.5)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(width: 38, h: 3, color: c.withValues(alpha: 0.8)),
                    const SizedBox(height: 1),
                    Container(height: 0.8, color: c.withValues(alpha: 0.5)),
                    const SizedBox(height: 3),
                    _line(width: double.infinity, h: 2, color: Colors.grey.shade300),
                    _line(width: 55, h: 2, color: Colors.grey.shade300),
                    const SizedBox(height: 5),
                    _line(width: 34, h: 3, color: c.withValues(alpha: 0.8)),
                    const SizedBox(height: 1),
                    Container(height: 0.8, color: c.withValues(alpha: 0.5)),
                    const SizedBox(height: 3),
                    _line(width: double.infinity, h: 2, color: Colors.grey.shade300),
                    _line(width: 44, h: 2, color: Colors.grey.shade300),
                  ],
                ),
              ),
            ),
          ],
        );

      case 'sidebar':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 32,
              color: c,
              padding: const EdgeInsets.fromLTRB(5, 6, 5, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width: 22, h: 4, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(height: 7),
                  _line(width: 18, h: 2, color: Colors.white.withValues(alpha: 0.6)),
                  _line(width: 20, h: 2, color: Colors.white.withValues(alpha: 0.6)),
                  _line(width: 14, h: 2, color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(height: 6),
                  _line(width: 17, h: 2, color: Colors.white.withValues(alpha: 0.6)),
                  _line(width: 19, h: 2, color: Colors.white.withValues(alpha: 0.6)),
                  _line(width: 13, h: 2, color: Colors.white.withValues(alpha: 0.6)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(width: 48, h: 3, color: c.withValues(alpha: 0.7)),
                    const SizedBox(height: 1),
                    Container(height: 0.8, color: c.withValues(alpha: 0.4)),
                    const SizedBox(height: 3),
                    _line(width: double.infinity, h: 2, color: Colors.grey.shade300),
                    _line(width: 42, h: 2, color: Colors.grey.shade300),
                    const SizedBox(height: 5),
                    _line(width: 38, h: 3, color: c.withValues(alpha: 0.7)),
                    const SizedBox(height: 1),
                    Container(height: 0.8, color: c.withValues(alpha: 0.4)),
                    const SizedBox(height: 3),
                    _line(width: double.infinity, h: 2, color: Colors.grey.shade300),
                    _line(width: 32, h: 2, color: Colors.grey.shade300),
                  ],
                ),
              ),
            ),
          ],
        );

      case 'timeline':
        return Padding(
          padding: const EdgeInsets.all(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line(width: 55, h: 5, color: const Color(0xFF1A1D23).withValues(alpha: 0.8)),
              const SizedBox(height: 1),
              _line(width: 24, h: 3, color: c.withValues(alpha: 0.8)),
              const SizedBox(height: 5),
              _line(width: 38, h: 3, color: c.withValues(alpha: 0.8)),
              const SizedBox(height: 1),
              Container(height: 0.8, color: c.withValues(alpha: 0.5)),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(children: [
                    Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                    Container(width: 1.5, height: 18, color: bg),
                    Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _line(width: double.infinity, h: 3,
                            color: const Color(0xFF1A1D23).withValues(alpha: 0.6)),
                        _line(width: 52, h: 2, color: Colors.grey.shade300),
                        _line(width: 38, h: 2, color: Colors.grey.shade300),
                        const SizedBox(height: 9),
                        _line(width: double.infinity, h: 3,
                            color: const Color(0xFF1A1D23).withValues(alpha: 0.6)),
                        _line(width: 42, h: 2, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'twocol':
        return Column(
          children: [
            Container(
              height: 20,
              color: c,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 7),
              child: _line(width: 55, h: 4,
                  color: Colors.white.withValues(alpha: 0.9)),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 38,
                    color: bg,
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _line(width: 28, h: 2.5, color: c.withValues(alpha: 0.8)),
                        Container(height: 0.5, color: c.withValues(alpha: 0.5)),
                        const SizedBox(height: 3),
                        _line(width: 26, h: 1.5, color: Colors.grey.shade400),
                        _line(width: 20, h: 1.5, color: Colors.grey.shade400),
                        _line(width: 24, h: 1.5, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  Container(width: 0.5, color: Colors.grey.shade300),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _line(width: 32, h: 2.5, color: c.withValues(alpha: 0.8)),
                          Container(height: 0.5, color: c.withValues(alpha: 0.5)),
                          const SizedBox(height: 3),
                          _line(width: double.infinity, h: 1.5, color: Colors.grey.shade400),
                          _line(width: 42, h: 1.5, color: Colors.grey.shade400),
                          _line(width: 32, h: 1.5, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      default: // single
        return Padding(
          padding: const EdgeInsets.all(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line(width: 60, h: 5,
                  color: const Color(0xFF1A1D23).withValues(alpha: 0.8)),
              const SizedBox(height: 2),
              _line(width: 78, h: 2, color: Colors.grey.shade300),
              const SizedBox(height: 3),
              Container(height: 1.5, color: c),
              const SizedBox(height: 5),
              _line(width: 38, h: 3, color: c.withValues(alpha: 0.8)),
              const SizedBox(height: 1),
              Container(height: 0.8, color: c.withValues(alpha: 0.4)),
              const SizedBox(height: 3),
              _line(width: double.infinity, h: 2, color: Colors.grey.shade300),
              _line(width: 60, h: 2, color: Colors.grey.shade300),
              const SizedBox(height: 5),
              _line(width: 34, h: 3, color: c.withValues(alpha: 0.8)),
              const SizedBox(height: 1),
              Container(height: 0.8, color: c.withValues(alpha: 0.4)),
              const SizedBox(height: 3),
              _line(width: double.infinity, h: 2, color: Colors.grey.shade300),
              _line(width: 48, h: 2, color: Colors.grey.shade300),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF252830) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 118,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08)),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini preview area
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Container(
                    height: 106,
                    width: double.infinity,
                    color: const Color(0xFFF8F9FA),
                    child: _buildPreview(),
                  ),
                ),
                // Footer: name + tier badge
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          template.name,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: template.tierColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            template.tierLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: template.tierColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Lock overlay
            if (!unlocked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.38),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: template.tierColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              template.tierLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Selected checkmark
            if (selected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

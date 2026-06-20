import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/resume/controller/resume_controller.dart';
import 'package:kitab_mandi/widgets/kitab_back_button.dart';

class ResumeFormView extends StatelessWidget {
  const ResumeFormView({super.key});

  static const _steps = [
    'Personal',
    'Education',
    'Skills',
    'Experience',
    'Projects',
    'Finalize',
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
                  child: const Text('Back',
                      style: TextStyle(fontWeight: FontWeight.w600)),
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
                            isLast ? 'Generate Resume ✨' : 'Continue',
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
      title: 'Personal Information',
      subtitle: 'Your contact details for the resume header',
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
      title: 'Education',
      subtitle: 'Your highest qualification',
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
      title: 'Skills',
      subtitle: 'Add your technical and soft skills',
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
      title: 'Work Experience',
      subtitle: 'Internships, jobs, or freelance projects',
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
                label: '+ Add Another Experience',
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
      title: 'Projects',
      subtitle: 'Personal, academic, or open-source projects',
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
                label: '+ Add Another Project',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _StepScaffold(
      icon: Icons.auto_awesome_rounded,
      title: 'Finalize & Generate',
      subtitle: 'Paste the job description for best ATS matching',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template picker
          Text('Resume Template',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 10),
          Obx(() => Row(
                children: [
                  _TemplateTile(
                    id: 'classic',
                    label: 'Classic',
                    icon: Icons.article_outlined,
                    desc: 'Clean & minimal',
                    selected: ctrl.selectedTemplate.value == 'classic',
                    onTap: () => ctrl.selectedTemplate.value = 'classic',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _TemplateTile(
                    id: 'modern',
                    label: 'Modern',
                    icon: Icons.dashboard_customize_rounded,
                    desc: 'Green header bar',
                    selected: ctrl.selectedTemplate.value == 'modern',
                    onTap: () => ctrl.selectedTemplate.value = 'modern',
                    isDark: isDark,
                  ),
                ],
              )),
          const SizedBox(height: 20),

          // Certifications
          _ChipInput(
            ctrl: ctrl.certCtrl,
            label: 'Certifications (optional)',
            hint: 'e.g. AWS Cloud Practitioner',
            chips: ctrl.certs,
            onAdd: ctrl.addCert,
            onRemove: ctrl.removeCert,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // JD
          Text('Target Job Description (optional)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text('Paste the JD to boost ATS keyword matching',
              style: TextStyle(fontSize: 11.5, color: theme.hintColor)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.jdCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Paste job description here…',
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
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),
          // AI disclaimer
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
                    'Claude AI will generate a full ATS-optimized resume. '
                    'Review and edit before sending.',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primary.withValues(alpha: 0.85),
                        height: 1.4),
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

class _TemplateTile extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final String desc;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _TemplateTile({
    required this.id,
    required this.label,
    required this.icon,
    required this.desc,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.025)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.black12),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 28,
                  color: selected ? AppColors.primary : Colors.grey),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text(desc,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}

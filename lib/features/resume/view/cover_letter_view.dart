import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/resume/controller/cover_letter_controller.dart';
import 'package:kitab_mandi/features/resume/controller/resume_controller.dart';
import 'package:kitab_mandi/features/resume/model/cover_letter_model.dart';

class CoverLetterView extends StatefulWidget {
  const CoverLetterView({super.key});

  @override
  State<CoverLetterView> createState() => _CoverLetterViewState();
}

class _CoverLetterViewState extends State<CoverLetterView> {
  late final CoverLetterController _ctrl;
  late final ResumeController _resumeCtrl;
  bool _jdExpanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<CoverLetterController>();
    _resumeCtrl = Get.find<ResumeController>();

    // Auto-select the latest resume if only one exists
    if (_resumeCtrl.resumes.isNotEmpty &&
        _ctrl.selectedResumeId.value.isEmpty) {
      _ctrl.selectedResumeId.value = _resumeCtrl.resumes.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumeSelector(theme, isDark),
                  const SizedBox(height: 16),
                  _buildFormCard(theme, isDark, size),
                  const SizedBox(height: 16),
                  _buildGenerateButton(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              final letter = _ctrl.generatedLetter.value;
              if (letter == null) return const SizedBox.shrink();
              return _buildResultCard(letter, theme, isDark);
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDark) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      leading: GestureDetector(
        onTap: Get.back,
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      ),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 10),
          const Text('AI Cover Letter',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildResumeSelector(ThemeData theme, bool isDark) {
    final resumes = _resumeCtrl.resumes;
    if (resumes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Build an AI Resume first — the cover letter pulls your data from it.',
                style: TextStyle(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurface,
                    height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    if (resumes.length == 1) {
      return _SectionLabel(
        icon: Icons.description_rounded,
        iconColor: AppColors.primary,
        label: 'Using resume:',
        value: resumes.first.data.contact.name,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select resume',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.hintColor)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resumes.map((r) {
                final selected = _ctrl.selectedResumeId.value == r.id;
                return GestureDetector(
                  onTap: () => _ctrl.selectedResumeId.value = r.id,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : (isDark
                              ? const Color(0xFF22252B)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : theme.dividerColor,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      r.data.contact.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : theme.hintColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, bool isDark, Size size) {
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _InputTile(
            icon: Icons.work_outline_rounded,
            hint: 'Job Title',
            sublabel: 'e.g. Software Engineer',
            controller: _ctrl.jobTitleCtrl,
            isFirst: true,
          ),
          Divider(height: 1, indent: 56, color: theme.dividerColor),
          _InputTile(
            icon: Icons.business_rounded,
            hint: 'Company Name',
            sublabel: 'e.g. Google, Amazon',
            controller: _ctrl.companyCtrl,
          ),
          Divider(height: 1, indent: 56, color: theme.dividerColor),
          // Optional JD expander
          GestureDetector(
            onTap: () => setState(() => _jdExpanded = !_jdExpanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.article_outlined,
                        size: 16, color: Color(0xFF1565C0)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Description',
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface),
                        ),
                        Text(
                          'Optional · improves letter quality',
                          style: TextStyle(
                              fontSize: 11, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _jdExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _jdExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _ctrl.jdCtrl,
                      maxLines: 6,
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText:
                            'Paste the job description here to get a perfectly tailored cover letter…',
                        hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: theme.hintColor,
                            height: 1.5),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF22252B)
                            : const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isDark) {
    return Obx(() {
      final loading = _ctrl.isGenerating.value;
      return GestureDetector(
        onTap: loading ? null : _ctrl.generate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: loading
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: loading ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: loading
                ? []
                : [
                    BoxShadow(
                      color:
                          const Color(0xFF1565C0).withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: loading
                ? [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    const Text('Generating…',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ]
                : [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text('Generate Cover Letter',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
          ),
        ),
      );
    });
  }

  Widget _buildResultCard(
      CoverLetterRecord letter, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cover Letter Ready',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface)),
                    Text('${letter.jobTitle} · ${letter.companyName}',
                        style: TextStyle(
                            fontSize: 12, color: theme.hintColor)),
                  ],
                ),
              ),
              // Copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: letter.letterText));
                  Get.snackbar(
                    'Copied!',
                    'Cover letter copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1B5E20),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF1565C0)
                            .withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 14, color: Color(0xFF1565C0)),
                      SizedBox(width: 5),
                      Text('Copy',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Letter body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1D23)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF1565C0).withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              letter.letterText,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.75,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.88),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Generate another hint
          Center(
            child: TextButton.icon(
              onPressed: _ctrl.resetForm,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Generate another'),
              style: TextButton.styleFrom(
                foregroundColor: theme.hintColor,
                textStyle: const TextStyle(fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable input tile ────────────────────────────────────────────────────────

class _InputTile extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String sublabel;
  final TextEditingController controller;
  final bool isFirst;

  const _InputTile({
    required this.icon,
    required this.hint,
    required this.sublabel,
    required this.controller,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    TextStyle(fontSize: 13.5, color: theme.hintColor),
                helperText: sublabel,
                helperStyle:
                    TextStyle(fontSize: 11, color: theme.hintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SectionLabel({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text('$label ',
            style: TextStyle(fontSize: 12.5, color: theme.hintColor)),
        Flexible(
          child: Text(value,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

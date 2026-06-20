import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/resume/model/resume_model.dart';
import 'package:kitab_mandi/features/resume/service/resume_pdf_service.dart';
import 'package:kitab_mandi/widgets/kitab_back_button.dart';

class ResumePreviewView extends StatefulWidget {
  const ResumePreviewView({super.key});

  @override
  State<ResumePreviewView> createState() => _ResumePreviewViewState();
}

class _ResumePreviewViewState extends State<ResumePreviewView> {
  bool _isDownloading = false;
  // PDF bytes cached so they are built once and reused for both preview
  // and download — no redundant local rendering, no API calls after generation.
  Uint8List? _cachedBytes;

  late final ResumeRecord _record;

  @override
  void initState() {
    super.initState();
    _record = Get.arguments as ResumeRecord;
    _warmCache();
  }

  Future<void> _warmCache() async {
    try {
      final bytes = await ResumePdfService.generate(_record);
      if (mounted) setState(() => _cachedBytes = bytes);
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Could not render PDF: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<Uint8List> _pdf(PdfPageFormat _) async {
    _cachedBytes ??= await ResumePdfService.generate(_record);
    return _cachedBytes!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const KitabBackButton(),
        title: Text('resume_preview_title'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : GestureDetector(
                    onTap: _cachedBytes == null ? null : _download,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _cachedBytes == null
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.download_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text('download'.tr,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          _StatsRow(record: _record, isDark: isDark),

          // PDF preview — reuses _cachedBytes, never calls Anthropic
          Expanded(
            child: PdfPreview(
              build: _pdf,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: '${_sanitize(_record.data.contact.name)}_resume.pdf',
              actions: const [],
              previewPageMargin: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),

      // ATS score bottom sheet trigger
      bottomNavigationBar: _ATSBar(record: _record, isDark: isDark),
    );
  }

  Future<void> _download() async {
    final bytes = _cachedBytes;
    if (bytes == null) return;
    setState(() => _isDownloading = true);
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_sanitize(_record.data.contact.name)}_resume.pdf',
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not share PDF: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final ResumeRecord record;
  final bool isDark;
  const _StatsRow({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final d = record.data;
    final kwCount = d.keywordsMatched.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            icon: Icons.key_rounded,
            value: '$kwCount',
            label: 'keywords_stat'.tr,
          ),
          _vDivider(),
          _Stat(
            icon: Icons.work_rounded,
            value: '${d.experience.length}',
            label: 'experiences_stat'.tr,
          ),
          _vDivider(),
          _Stat(
            icon: Icons.rocket_launch_rounded,
            value: '${d.projects.length}',
            label: 'projects_stat'.tr,
          ),
          _vDivider(),
          _Stat(
            icon: Icons.code_rounded,
            value: '${d.skills.technical.length}',
            label: 'skills_stat'.tr,
          ),
          _vDivider(),
          _AiModelStat(model: record.aiModel),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
      height: 28, width: 1,
      color: AppColors.primary.withValues(alpha: 0.2));
}

class _AiModelStat extends StatelessWidget {
  final String? model;
  const _AiModelStat({this.model});

  @override
  Widget build(BuildContext context) {
    final isSonnet = model?.contains('sonnet') ?? false;
    final label = isSonnet ? 'Sonnet' : 'Haiku'; // model names are brand names
    final color = isSonnet ? const Color(0xFFF59E0B) : AppColors.primary;
    final icon = isSonnet
        ? Icons.workspace_premium_rounded
        : Icons.auto_awesome_rounded;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text('ai_model_stat'.tr,
            style: TextStyle(
                fontSize: 9.5, color: Theme.of(context).hintColor)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary)),
        Text(label,
            style:
                TextStyle(fontSize: 9.5, color: Theme.of(context).hintColor)),
      ],
    );
  }
}

// ─── ATS bottom bar ───────────────────────────────────────────────────────────

class _ATSBar extends StatelessWidget {
  final ResumeRecord record;
  final bool isDark;
  const _ATSBar({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final keywords = record.data.keywordsMatched;
    if (keywords.isEmpty) return const SizedBox.shrink();

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 5),
              Text('${'ats_keywords_matched'.tr} (${keywords.length})',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: keywords
                .take(12)
                .map((k) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(k,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

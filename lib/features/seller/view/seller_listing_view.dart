import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/seller/controller/seller_controller.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';
import 'package:kitab_mandi/widgets/notification_bell.dart';

class SellerListingView extends StatelessWidget {
  SellerListingView({super.key});

  final controller = Get.find<SellerController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sw = MediaQuery.sizeOf(context).width;
    final hPad = (sw * 0.048).clamp(14.0, 24.0);
    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.isEdit.value ? 'edit_listing'.tr : 'sell_item'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                controller.isEdit.value
                    ? 'update_listing_subtitle'.tr
                    : 'fill_details_below'.tr,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        actions: const [NotificationBell(), SizedBox(width: 4)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.white24),
        ),
      ),

      // ── Sticky submit button ───────────────────────────────────────────────
      bottomNavigationBar: _SubmitBar(
        controller: controller,
        isDark: isDark,
        hPad: hPad,
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
        child: Column(
          children: [
            // ── Step 1: Photos ─────────────────────────────────────────
            _SectionCard(
              step: 1,
              title: 'step_photos'.tr,
              subtitle: 'step_photos_subtitle'.tr,
              icon: Icons.camera_alt_rounded,
              isDark: isDark,
              theme: theme,
              child: _ImagesSection(
                controller: controller,
                isDark: isDark,
                theme: theme,
              ),
            ),

            const SizedBox(height: 16),

            // ── Step 2: Category ───────────────────────────────────────
            _SectionCard(
              step: 2,
              title: 'step_category'.tr,
              subtitle: 'step_category_subtitle'.tr,
              icon: Icons.category_rounded,
              isDark: isDark,
              theme: theme,
              child: _CategorySection(
                controller: controller,
                isDark: isDark,
                theme: theme,
              ),
            ),

            const SizedBox(height: 16),

            // ── Step 3: Details ────────────────────────────────────────
            _SectionCard(
              step: 3,
              title: 'step_details'.tr,
              subtitle: 'step_details_subtitle'.tr,
              icon: Icons.edit_note_rounded,
              isDark: isDark,
              theme: theme,
              child: _DetailsSection(
                controller: controller,
                isDark: isDark,
                theme: theme,
              ),
            ),

            const SizedBox(height: 16),

            // ── Step 4: Condition ──────────────────────────────────────
            _SectionCard(
              step: 4,
              title: 'step_condition'.tr,
              subtitle: 'step_condition_subtitle'.tr,
              icon: Icons.stars_rounded,
              isDark: isDark,
              theme: theme,
              child: _ConditionSection(
                controller: controller,
                isDark: isDark,
                theme: theme,
              ),
            ),

            const SizedBox(height: 16),

            // ── Step 5: Location ───────────────────────────────────────
            _SectionCard(
              step: 5,
              title: 'step_location'.tr,
              subtitle: 'step_location_subtitle'.tr,
              icon: Icons.location_on_rounded,
              isDark: isDark,
              theme: theme,
              child: _LocationSection(
                controller: controller,
                isDark: isDark,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section card with numbered step ──────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final ThemeData theme;
  final Widget child;

  const _SectionCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor),

          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ── Submit bar ────────────────────────────────────────────────────────────────
class _SubmitBar extends StatelessWidget {
  final SellerController controller;
  final bool isDark;
  final double hPad;

  const _SubmitBar({
    required this.controller,
    required this.isDark,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    final barBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
      child: Obx(
        () => GestureDetector(
          onTap: controller.isUploading.value ? null : controller.uploadListing,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              gradient: controller.isUploading.value
                  ? null
                  : AppColors.primaryGradient,
              color: controller.isUploading.value
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: controller.isUploading.value
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: controller.isUploading.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_upload_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.isEdit.value
                              ? 'update_listing'.tr
                              : 'post_ad'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Images section ────────────────────────────────────────────────────────────
class _ImagesSection extends StatelessWidget {
  final SellerController controller;
  final bool isDark;
  final ThemeData theme;

  const _ImagesSection({
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                ...controller.images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final img = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: img.startsWith('http')
                              ? Image.network(
                                  img,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(img),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        // Main badge
                        if (index == 0)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'main_badge'.tr,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        // Remove button
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => controller.removeImage(index),
                            child: Container(
                              height: 22,
                              width: 22,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Add button
                GestureDetector(
                  onTap: () => _showImagePickerSheet(context, controller),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                        // Dashed via CustomPaint is complex — using solid with low opacity
                      ),
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : AppColors.primary.withValues(alpha: 0.04),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'add_photo'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Counter + tip
          Row(
            children: [
              Obx(
                () => _CounterBadge(
                  current: controller.images.length,
                  max: 3,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'first_photo_cover'.tr,
                  style: TextStyle(fontSize: 11.5, color: theme.hintColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final int current;
  final int max;
  final ThemeData theme;

  const _CounterBadge({
    required this.current,
    required this.max,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final full = current >= max;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: full
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$current / $max ${'photos_label'.tr}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: full ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }
}

// ── Image source picker ───────────────────────────────────────────────────────
void _showImagePickerSheet(BuildContext context, SellerController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ImagePickerSheet(controller: controller),
  );
}

class _ImagePickerSheet extends StatelessWidget {
  final SellerController controller;
  const _ImagePickerSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final surfaceColor =
        isDark ? const Color(0xFF23272F) : const Color(0xFFF5F6FA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.hintColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 20),

          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'add_photo'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'choose_photo_source'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Option cards ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _PickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'camera'.tr,
                  sublabel: 'take_new_photo'.tr,
                  gradientColors: const [Color(0xFF6C63FF), Color(0xFF9C95FF)],
                  surfaceColor: surfaceColor,
                  isDark: isDark,
                  theme: theme,
                  onTap: () {
                    Get.back();
                    controller.pickImage(source: ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'gallery'.tr,
                  sublabel: 'pick_existing_photo'.tr,
                  gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                  surfaceColor: surfaceColor,
                  isDark: isDark,
                  theme: theme,
                  onTap: () {
                    Get.back();
                    controller.pickImage(source: ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Cancel ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor: theme.hintColor,
              ),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final List<Color> gradientColors;
  final Color surfaceColor;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradientColors,
    required this.surfaceColor,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category section ──────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final SellerController controller;
  final bool isDark;
  final ThemeData theme;

  const _CategorySection({
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: 'field_category'.tr, theme: theme),
          const SizedBox(height: 8),
          _PillWrap(
            items: controller.categories
                .map((e) => e['name'] as String)
                .toList()
                .cast<String>(),
            selected: controller.selectedMain.value,
            onTap: (val) {
              controller.selectedMain.value = val;
              controller.selectedSub.value = '';
              controller.selectedChild.value = '';
            },
            isDark: isDark,
            theme: theme,
          ),

          if (controller.selectedMain.isNotEmpty) ...[
            const SizedBox(height: 16),
            _FieldLabel(label: controller.subTitle, theme: theme),
            const SizedBox(height: 8),
            _PillWrap(
              items: controller.subCategories
                  .map((e) => e['name'] as String)
                  .toList()
                  .cast<String>(),
              selected: controller.selectedSub.value,
              onTap: (val) {
                controller.selectedSub.value = val;
                controller.selectedChild.value = '';
              },
              isDark: isDark,
              theme: theme,
            ),
          ],

          if (controller.childCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            _FieldLabel(label: controller.childTitle, theme: theme),
            const SizedBox(height: 8),
            _PillWrap(
              items: controller.childCategories
                  .map((e) => e['name'] as String)
                  .toList(),
              selected: controller.selectedChild.value,
              onTap: (val) => controller.selectedChild.value = val,
              isDark: isDark,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Details section ───────────────────────────────────────────────────────────
class _DetailsSection extends StatelessWidget {
  final SellerController controller;
  final bool isDark;
  final ThemeData theme;

  const _DetailsSection({
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'field_title'.tr, theme: theme),
        const SizedBox(height: 6),
        AppTextField(
          controller: controller.titleController,
          hintText: 'hint_book_title'.tr,
          prefixIcon: const Icon(Icons.title_rounded),
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 14),

        _FieldLabel(label: 'field_price'.tr, theme: theme),
        const SizedBox(height: 6),
        AppTextField(
          controller: controller.priceController,
          hintText: 'hint_enter_price'.tr,
          prefixIcon: const Icon(Icons.currency_rupee_rounded),
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 14),

        _FieldLabel(label: 'field_description'.tr, theme: theme),
        const SizedBox(height: 6),
        AppTextField(
          controller: controller.descriptionController,
          hintText: 'hint_describe_book'.tr,
          maxLines: 4,
          textInputAction: TextInputAction.done,
        ),

        const SizedBox(height: 6),

        Align(
          alignment: Alignment.centerRight,
          child: _CharCount(
            controller: controller.descriptionController,
            max: 500,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _CharCount extends StatefulWidget {
  final TextEditingController controller;
  final int max;
  final ThemeData theme;

  const _CharCount({
    required this.controller,
    required this.max,
    required this.theme,
  });

  @override
  State<_CharCount> createState() => _CharCountState();
}

class _CharCountState extends State<_CharCount> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final len = widget.controller.text.length;
    final near = len > widget.max * 0.8;
    return Text(
      '$len / ${widget.max}',
      style: TextStyle(
        fontSize: 11,
        color: near ? AppColors.warning : widget.theme.hintColor,
        fontWeight: near ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

// ── Condition section ─────────────────────────────────────────────────────────
class _ConditionSection extends StatelessWidget {
  final SellerController controller;
  final bool isDark;
  final ThemeData theme;

  const _ConditionSection({
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  static Map<String, (IconData, String)> _conditionMeta() => {
    'New': (Icons.auto_awesome_rounded, 'cond_new_desc'.tr),
    'Like New': (Icons.grade_rounded, 'cond_like_new_desc'.tr),
    'Used': (Icons.menu_book_rounded, 'cond_used_desc'.tr),
  };

  static String _condLabel(String cond) {
    switch (cond) {
      case 'New': return 'cond_new'.tr;
      case 'Like New': return 'cond_like_new'.tr;
      case 'Used': return 'cond_used'.tr;
      default: return cond;
    }
  }

  @override
  Widget build(BuildContext context) {
    final condMeta = _conditionMeta();
    return Column(
      children: controller.conditions.map((cond) {
        final meta = condMeta[cond];
        final icon = meta?.$1 ?? Icons.circle;
        final desc = meta?.$2 ?? '';
        return Obx(() {
          final selected = controller.selectedCondition.value == cond;
          return GestureDetector(
            onTap: () => controller.selectedCondition.value = cond,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : isDark
                    ? const Color(0xFF22252B)
                    : const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.hintColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _condLabel(cond),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.hintColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}

// ── Location section ──────────────────────────────────────────────────────────
class _LocationSection extends StatelessWidget {
  final SellerController controller;
  final bool isDark;
  final ThemeData theme;

  const _LocationSection({
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasAddr = controller.fullAddress.value.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasAddr
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : isDark
                  ? const Color(0xFF22252B)
                  : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasAddr
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasAddr
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  child: Icon(
                    hasAddr
                        ? Icons.location_on_rounded
                        : Icons.location_off_rounded,
                    size: 20,
                    color: hasAddr ? AppColors.primary : theme.hintColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAddr ? 'location_detected'.tr : 'no_location_yet'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasAddr ? AppColors.primary : theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasAddr
                            ? controller.fullAddress.value
                            : 'tap_detect_location'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasAddr
                              ? theme.textTheme.bodyMedium?.color
                              : theme.hintColor,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Detect button
          GestureDetector(
            onTap: controller.isDetectingLocation.value
                ? null
                : controller.detectLocation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 44,
              decoration: BoxDecoration(
                gradient: controller.isDetectingLocation.value
                    ? null
                    : AppColors.primaryGradient,
                color: controller.isDetectingLocation.value
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: controller.isDetectingLocation.value
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Center(
                child: controller.isDetectingLocation.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasAddr ? 're_detect_location'.tr : 'detect'.tr,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Shared pill wrap ──────────────────────────────────────────────────────────
class _PillWrap extends StatelessWidget {
  final List<String> items;
  final String selected;
  final void Function(String) onTap;
  final bool isDark;
  final ThemeData theme;

  const _PillWrap({
    required this.items,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDark
                  ? const Color(0xFF22252B)
                  : const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _FieldLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: theme.hintColor,
        letterSpacing: 0.2,
      ),
    );
  }
}

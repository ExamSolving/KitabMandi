import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FilterScreen — industry-level premium filter UI
// ─────────────────────────────────────────────────────────────────────────────
class FilterScreen extends StatelessWidget {
  FilterScreen({super.key});

  final filterCtrl = Get.find<FilterController>();

  static const List<Map<String, Object>> _conditions = [
    {
      'title': 'New',
      'desc': 'Unused, sealed or mint condition',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFF4DA3FF),
    },
    {
      'title': 'Like New',
      'desc': 'Lightly used, no visible wear',
      'icon': Icons.thumb_up_alt_rounded,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Used',
      'desc': 'Some wear but works perfectly',
      'icon': Icons.refresh_rounded,
      'color': Color(0xFFFFA726),
    },
  ];

  static const List<Map<String, Object>> _sortOptions = [
    {
      'label': 'Price: Low to High',
      'icon': Icons.trending_up_rounded,
    },
    {
      'label': 'Price: High to Low',
      'icon': Icons.trending_down_rounded,
    },
    {
      'label': 'Newest First',
      'icon': Icons.schedule_rounded,
    },
  ];

  static const List<Map<String, Object>> _distanceOptions = [
    {'km': -1.0, 'label': 'Any'},
    {'km': 1.0, 'label': '1 km'},
    {'km': 2.0, 'label': '2 km'},
    {'km': 5.0, 'label': '5 km'},
    {'km': 10.0, 'label': '10 km'},
    {'km': 25.0, 'label': '25 km'},
    {'km': 50.0, 'label': '50 km'},
  ];

  int _activeCount() {
    int c = 0;
    if (filterCtrl.selectedCategory.value.isNotEmpty) c++;
    if (filterCtrl.selectedSubCategory.value.isNotEmpty) c++;
    if (filterCtrl.selectedType.value.isNotEmpty) c++;
    c += filterCtrl.selectedConditions.length;
    if (filterCtrl.selectedSort.value.isNotEmpty) c++;
    if (filterCtrl.selectedDistanceKm.value != 0.0) c++;
    if (filterCtrl.minPrice.value > 0 || filterCtrl.maxPrice.value < 5000) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    final cardBg = isDark ? const Color(0xFF171B22) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final count = _activeCount();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'filters_title'.tr,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
        actions: [
          Obx(() {
            final hasAny = _activeCount() > 0;
            return TextButton(
              onPressed: hasAny
                  ? () {
                      HapticFeedback.lightImpact();
                      filterCtrl.reset();
                    }
                  : null,
              child: Text(
                'reset'.tr,
                style: TextStyle(
                  color: hasAny
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.dividerColor),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Distance ─────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.near_me_rounded,
                      title: 'filter_distance'.tr,
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _DistanceRow(
                      filterCtrl: filterCtrl,
                      isDark: isDark,
                      theme: theme,
                      cardBg: cardBg,
                      options: _distanceOptions,
                    ),
                    const SizedBox(height: 28),
                    _SectionDivider(isDark: isDark),
                    const SizedBox(height: 28),

                    // ── Category ─────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.grid_view_rounded,
                      title: 'category'.tr,
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _CategorySection(
                      filterCtrl: filterCtrl,
                      isDark: isDark,
                      theme: theme,
                      cardBg: cardBg,
                    ),
                    const SizedBox(height: 28),
                    _SectionDivider(isDark: isDark),
                    const SizedBox(height: 28),

                    // ── Price Range ───────────────────────────────────
                    _SectionHeader(
                      icon: Icons.payments_outlined,
                      title: 'filter_price_range'.tr,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _PriceSection(
                      filterCtrl: filterCtrl,
                      isDark: isDark,
                      theme: theme,
                      cardBg: cardBg,
                    ),
                    const SizedBox(height: 28),
                    _SectionDivider(isDark: isDark),
                    const SizedBox(height: 28),

                    // ── Condition ─────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.verified_rounded,
                      title: 'condition'.tr,
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _ConditionSection(
                      filterCtrl: filterCtrl,
                      conditions: _conditions,
                      isDark: isDark,
                      theme: theme,
                      cardBg: cardBg,
                    ),
                    const SizedBox(height: 28),
                    _SectionDivider(isDark: isDark),
                    const SizedBox(height: 28),

                    // ── Sort By ───────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.swap_vert_rounded,
                      title: 'filter_sort_by'.tr,
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _SortSection(
                      filterCtrl: filterCtrl,
                      options: _sortOptions,
                      isDark: isDark,
                      theme: theme,
                      cardBg: cardBg,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Sticky apply bar ───────────────────────────────────────
            _ApplyBar(
              filterCtrl: filterCtrl,
              activeCountFn: _activeCount,
              cardBg: cardBg,
              isDark: isDark,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header — accent bar + icon + title
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtle section divider
// ─────────────────────────────────────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  final bool isDark;
  const _SectionDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Distance — horizontally scrollable pill row
// ─────────────────────────────────────────────────────────────────────────────
class _DistanceRow extends StatelessWidget {
  final FilterController filterCtrl;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;
  final List<Map<String, Object>> options;

  const _DistanceRow({
    required this.filterCtrl,
    required this.isDark,
    required this.theme,
    required this.cardBg,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(options.length, (i) {
              final km = options[i]['km'] as double;
              final label = options[i]['label'] as String;
              final selected = filterCtrl.selectedDistanceKm.value == km;
              return Padding(
                padding:
                    EdgeInsets.only(right: i < options.length - 1 ? 10 : 0),
                child: _PillChip(
                  label: label,
                  selected: selected,
                  isDark: isDark,
                  theme: theme,
                  cardBg: cardBg,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    filterCtrl.selectedDistanceKm.value = km;
                  },
                ),
              );
            }),
          ),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category — cascading main → sub → type chips
// ─────────────────────────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final FilterController filterCtrl;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;

  const _CategorySection({
    required this.filterCtrl,
    required this.isDark,
    required this.theme,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = filterCtrl.categoriesData;
      final selectedCat = filterCtrl.selectedCategory.value;
      final selectedSub = filterCtrl.selectedSubCategory.value;
      final selectedType = filterCtrl.selectedType.value;

      final catObj = categories.cast<dynamic>().firstWhere(
            (e) => e['name'] == selectedCat,
            orElse: () => null,
          );
      final subCategories =
          (catObj?['subcategories'] as List?) ?? [];

      final subObj = subCategories.firstWhere(
        (e) => e['name'] == selectedSub,
        orElse: () => null,
      );
      final types = (subObj?['children'] as List?) ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main category
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map<Widget>((cat) {
              final sel = selectedCat == cat['name'];
              return _PillChip(
                label: cat['name'] as String,
                selected: sel,
                isDark: isDark,
                theme: theme,
                cardBg: cardBg,
                onTap: () {
                  HapticFeedback.selectionClick();
                  filterCtrl.selectedCategory.value = cat['name'] as String;
                  filterCtrl.selectedSubCategory.value = '';
                  filterCtrl.selectedType.value = '';
                },
              );
            }).toList(),
          ),

          // Sub category (animated reveal)
          if (subCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SubSectionLabel(label: _subLabel(selectedCat), theme: theme),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: subCategories.map<Widget>((sub) {
                final sel = selectedSub == sub['name'];
                return _PillChip(
                  label: sub['name'] as String,
                  selected: sel,
                  isDark: isDark,
                  theme: theme,
                  cardBg: cardBg,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    filterCtrl.selectedSubCategory.value =
                        sub['name'] as String;
                    filterCtrl.selectedType.value = '';
                  },
                );
              }).toList(),
            ),
          ],

          // Type (animated reveal)
          if (types.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SubSectionLabel(label: _typeLabel(selectedCat), theme: theme),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: types.map<Widget>((type) {
                final name = (type is Map)
                    ? (type['name'] as String? ?? type.toString())
                    : type.toString();
                final sel = selectedType == name;
                return _PillChip(
                  label: name,
                  selected: sel,
                  isDark: isDark,
                  theme: theme,
                  cardBg: cardBg,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    filterCtrl.selectedType.value = name;
                  },
                );
              }).toList(),
            ),
          ],
        ],
      );
    });
  }

  String _subLabel(String cat) {
    switch (cat) {
      case 'School Books':
        return 'Board';
      case 'Academic Books':
        return 'Stream';
      case 'Competitive Exams':
        return 'Exam Type';
      default:
        return 'Sub Category';
    }
  }

  String _typeLabel(String cat) {
    switch (cat) {
      case 'School Books':
        return 'Class';
      case 'Academic Books':
        return 'Branch';
      case 'Competitive Exams':
        return 'Exam';
      default:
        return 'Type';
    }
  }
}

class _SubSectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SubSectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.subdirectory_arrow_right_rounded,
            size: 14, color: theme.hintColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.hintColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price Range — two labeled boxes + range slider
// ─────────────────────────────────────────────────────────────────────────────
class _PriceSection extends StatelessWidget {
  final FilterController filterCtrl;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;

  const _PriceSection({
    required this.filterCtrl,
    required this.isDark,
    required this.theme,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Obx(() {
      final min = filterCtrl.minPrice.value;
      final max = filterCtrl.maxPrice.value;

      return Column(
        children: [
          // Min / Max display boxes
          Row(
            children: [
              Expanded(
                child: _PriceBox(
                  label: 'filter_min_price'.tr,
                  value: '₹${min.toInt()}',
                  isDark: isDark,
                  theme: theme,
                  cardBg: cardBg,
                  isActive: min > 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 24,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Expanded(
                child: _PriceBox(
                  label: 'filter_max_price'.tr,
                  value: '₹${max.toInt()}',
                  isDark: isDark,
                  theme: theme,
                  cardBg: cardBg,
                  isActive: max < 5000,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Range slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primary,
              inactiveTrackColor:
                  isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
              thumbColor: primary,
              overlayColor: primary.withValues(alpha: 0.15),
              trackHeight: 4,
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 11),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 22),
              valueIndicatorColor: primary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: RangeSlider(
              values: RangeValues(min, max),
              min: 0,
              max: 5000,
              divisions: 100,
              labels: RangeLabels(
                '₹${min.toInt()}',
                '₹${max.toInt()}',
              ),
              onChanged: (v) {
                filterCtrl.minPrice.value = v.start;
                filterCtrl.maxPrice.value = v.end;
              },
            ),
          ),

          // Scale labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹0',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500)),
                Text('₹5,000',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;
  final bool isActive;

  const _PriceBox({
    required this.label,
    required this.value,
    required this.isDark,
    required this.theme,
    required this.cardBg,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? primary.withValues(alpha: isDark ? 0.14 : 0.07) : cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? primary.withValues(alpha: 0.4)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.07)),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isActive ? primary : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Condition — full-width selectable cards
// ─────────────────────────────────────────────────────────────────────────────
class _ConditionSection extends StatelessWidget {
  final FilterController filterCtrl;
  final List<Map<String, Object>> conditions;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;

  const _ConditionSection({
    required this.filterCtrl,
    required this.conditions,
    required this.isDark,
    required this.theme,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: conditions.map((c) {
            final title = c['title'] as String;
            final desc = c['desc'] as String;
            final icon = c['icon'] as IconData;
            final color = c['color'] as Color;
            final selected =
                filterCtrl.selectedConditions.contains(title);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  filterCtrl.toggleItem(
                      filterCtrl.selectedConditions, title);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(
                            alpha: isDark ? 0.12 : 0.07)
                        : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.5)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.07)),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              color.withValues(alpha: 0.12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      // Labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: selected
                                    ? color
                                    : theme
                                        .textTheme.bodyLarge?.color,
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
                      const SizedBox(width: 12),
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? color : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? color
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.2)),
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 13, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort By — full-width selectable card rows
// ─────────────────────────────────────────────────────────────────────────────
class _SortSection extends StatelessWidget {
  final FilterController filterCtrl;
  final List<Map<String, Object>> options;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;

  const _SortSection({
    required this.filterCtrl,
    required this.options,
    required this.isDark,
    required this.theme,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Obx(() => Column(
          children: options.map((opt) {
            final label = opt['label'] as String;
            final icon = opt['icon'] as IconData;
            final selected = filterCtrl.selectedSort.value == label;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  filterCtrl.selectedSort.value = label;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? primary.withValues(
                            alpha: isDark ? 0.12 : 0.07)
                        : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? primary.withValues(alpha: 0.45)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.07)),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (selected ? primary : theme.hintColor)
                              .withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          icon,
                          size: 18,
                          color: selected ? primary : theme.hintColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Label
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                            color: selected
                                ? primary
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      // Radio circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              selected ? primary : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.2)),
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 13, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable pill chip (distance + category)
// ─────────────────────────────────────────────────────────────────────────────
class _PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;
  final VoidCallback onTap;

  const _PillChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.theme,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: selected ? null : cardBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_rounded,
                  size: 13, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky apply button with gradient + active filter count badge
// ─────────────────────────────────────────────────────────────────────────────
class _ApplyBar extends StatelessWidget {
  final FilterController filterCtrl;
  final int Function() activeCountFn;
  final Color cardBg;
  final bool isDark;
  final ThemeData theme;

  const _ApplyBar({
    required this.filterCtrl,
    required this.activeCountFn,
    required this.cardBg,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Obx(() {
      final count = activeCountFn();
      return Container(
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: isDark ? 0.25 : 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, AppColors.primaryDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                filterCtrl.applyFilters();
                Get.back(result: filterCtrl);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'apply_filters'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

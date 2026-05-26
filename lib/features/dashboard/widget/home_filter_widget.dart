import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';

class FilterScreen extends StatelessWidget {
  FilterScreen({super.key});

  final controller = Get.put(FilterController());

  final categories = [
    {
      "title": "Collage Books",
      "icon": Icons.menu_book_rounded,
      "color": const Color(0xFF7CFFB2),
    },
    {
      "title": "Notes",
      "icon": Icons.notes_rounded,
      "color": const Color(0xFF7DF9FF),
    },
    {
      "title": "Magazines",
      "icon": Icons.auto_stories_rounded,
      "color": const Color(0xFFC77DFF),
    },
    {
      "title": "Competitive Exams",
      "icon": Icons.school_rounded,
      "color": const Color(0xFFFF6B81),
    },
    {
      "title": "School Books",
      "icon": Icons.backpack_rounded,
      "color": const Color(0xFFFF9F43),
    },
  ];

  final conditions = [
    {
      "title": "New",
      "icon": Icons.auto_awesome_rounded,
      "color": const Color(0xFF4DA3FF),
    },
    {
      "title": "Like New",
      "icon": Icons.thumb_up_alt_rounded,
      "color": const Color(0xFF6DDB5F),
    },
    {
      "title": "Used",
      "icon": Icons.refresh_rounded,
      "color": const Color(0xFFFFC107),
    },
  ];

  final sortOptions = [
    "Price: Low to High",
    "Price: High to Low",
    "Newest First",
  ];

  double responsiveText(
    BuildContext context, {
    required double mobile,
    double? tablet,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width > 600) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  Color _appBarBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width > 600;

    final bool isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF7F8FA);

    final cardColor = isDark ? const Color(0xFF171B22) : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);

    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    final borderColor = isDark
        ? Colors.green.withOpacity(0.35)
        : Colors.green.withOpacity(0.18);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _appBarBg(context),

        // leading: IconButton(
        //   onPressed: () => Get.back(),

        //   icon: Icon(
        //     Icons.arrow_back_ios_new_rounded,
        //     color: primaryText,
        //     size: 16,
        //   ),
        // ),
        title: Text(
          "Filters",
          style: theme.textTheme.titleLarge?.copyWith(
            color: primaryText,
            fontWeight: FontWeight.w600,
            fontSize: responsiveText(context, mobile: 20, tablet: 25),
          ),
        ),

        actions: [
          TextButton(
            onPressed: controller.reset,

            child: Text(
              "Reset",

              style: TextStyle(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w600,
                fontSize: responsiveText(context, mobile: 13, tablet: 14),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// DISTANCE
                    _sectionTitle(context, "Distance", primaryText),

                    const SizedBox(height: 12),

                    Obx(
                      () => Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: [1, 2, 3, 5, 10].map((km) {
                          final selected =
                              controller.selectedDistanceKm.value ==
                              km.toDouble();

                          return GestureDetector(
                            onTap: () {
                              controller.selectedDistanceKm.value = km
                                  .toDouble();
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),

                              width: isTablet ? 130 : 80,
                              height: isTablet ? 58 : 40,

                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF5DD65D)
                                    : cardColor,

                                borderRadius: BorderRadius.circular(16),

                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : borderColor,
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Text(
                                    "$km km",

                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : primaryText,

                                      fontWeight: FontWeight.w700,

                                      fontSize: responsiveText(
                                        context,
                                        mobile: 14,
                                        tablet: 16,
                                      ),
                                    ),
                                  ),

                                  if (selected) ...[
                                    const SizedBox(width: 8),

                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),

                                      child: const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Color(0xFF5DD65D),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// CATEGORY
                    _sectionTitle(context, "Category", primaryText),

                    const SizedBox(height: 12),

                    Obx(
                      () => Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: categories.map((category) {
                          final selected = controller.selectedCategories
                              .contains(category['title']);

                          return GestureDetector(
                            onTap: () {
                              controller.toggleItem(
                                controller.selectedCategories,
                                category['title'].toString(),
                              );
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),

                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.green.withOpacity(
                                        isDark ? 0.15 : 0.08,
                                      )
                                    : cardColor,

                                borderRadius: BorderRadius.circular(16),

                                border: Border.all(
                                  color: selected ? Colors.green : borderColor,
                                ),
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(
                                    category['icon'] as IconData,
                                    size: 16,
                                    color: category['color'] as Color,
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    category['title'].toString(),

                                    style: TextStyle(
                                      color: primaryText,
                                      fontWeight: FontWeight.w600,

                                      fontSize: responsiveText(
                                        context,
                                        mobile: 13,
                                        tablet: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// PRICE RANGE
                    _sectionTitle(context, "Price Range", primaryText),

                    const SizedBox(height: 6),

                    Obx(
                      () => SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.green.shade400,
                          inactiveTrackColor: isDark
                              ? Colors.white10
                              : Colors.black12,

                          thumbColor: Colors.green.shade400,

                          overlayColor: Colors.green.withOpacity(0.12),

                          trackHeight: 5,

                          rangeThumbShape: const RoundRangeSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                        ),

                        child: RangeSlider(
                          values: RangeValues(
                            controller.minPrice.value,
                            controller.maxPrice.value,
                          ),

                          min: 0,
                          max: 5000,

                          onChanged: (values) {
                            controller.minPrice.value = values.start;
                            controller.maxPrice.value = values.end;
                          },
                        ),
                      ),
                    ),

                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            "₹0",

                            style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),

                          Text(
                            "₹${controller.minPrice.value.toInt()} - ₹${controller.maxPrice.value.toInt()}",

                            style: TextStyle(
                              color: Colors.green.shade400,
                              fontWeight: FontWeight.w700,

                              fontSize: responsiveText(
                                context,
                                mobile: 14,
                                tablet: 15,
                              ),
                            ),
                          ),

                          Text(
                            "₹5000",

                            style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// CONDITION
                    _sectionTitle(context, "Condition", primaryText),

                    const SizedBox(height: 12),

                    Obx(
                      () => Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: conditions.map((condition) {
                          final selected = controller.selectedConditions
                              .contains(condition['title']);

                          return GestureDetector(
                            onTap: () {
                              controller.toggleItem(
                                controller.selectedConditions,
                                condition['title'].toString(),
                              );
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),

                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.green.withOpacity(
                                        isDark ? 0.15 : 0.08,
                                      )
                                    : cardColor,

                                borderRadius: BorderRadius.circular(16),

                                border: Border.all(
                                  color: selected ? Colors.green : borderColor,
                                ),
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(
                                    condition['icon'] as IconData,
                                    size: 20,
                                    color: condition['color'] as Color,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    condition['title'].toString(),

                                    style: TextStyle(
                                      color: primaryText,
                                      fontWeight: FontWeight.w600,

                                      fontSize: responsiveText(
                                        context,
                                        mobile: 13,
                                        tablet: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// SORT
                    _sectionTitle(context, "Sort By", primaryText),

                    const SizedBox(height: 10),

                    Obx(
                      () => Column(
                        children: sortOptions.map((e) {
                          final selected = controller.selectedSort.value == e;

                          return GestureDetector(
                            onTap: () {
                              controller.selectedSort.value = e;
                            },

                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),

                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),

                                    width: 24,
                                    height: 24,

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      border: Border.all(
                                        color: selected
                                            ? Colors.green.shade400
                                            : secondaryText,
                                        width: 2,
                                      ),
                                    ),

                                    child: selected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,

                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green.shade400,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),

                                  const SizedBox(width: 14),

                                  Text(
                                    e,

                                    style: TextStyle(
                                      color: primaryText,
                                      fontWeight: FontWeight.w500,

                                      fontSize: responsiveText(
                                        context,
                                        mobile: 14,
                                        tablet: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            /// APPLY BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),

              decoration: BoxDecoration(
                color: bgColor,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),

              child: SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.secondaryDark,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () {
                    final homeCtrl = Get.put(HomeController());

                    homeCtrl.applyFilters();

                    Get.back(result: controller);
                  },

                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),

                  label: Text(
                    "Apply Filters",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,

                      fontSize: responsiveText(context, mobile: 15, tablet: 17),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, Color color) {
    return Text(
      title,

      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: color,
      ),
    );
  }
}

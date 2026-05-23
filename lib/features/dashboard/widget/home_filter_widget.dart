import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';

class FilterScreen extends StatelessWidget {
  FilterScreen({super.key});

  final controller = Get.put(FilterController());

  final categories = [
    "Books",
    "Notes",
    "Magazines",
    "Competitive Exams",
    "School Books",
  ];

  final conditions = ["New", "Like New", "Used"];

  final sortOptions = [
    "Price: Low to High",
    "Price: High to Low",
    "Newest First",
  ];

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
        backgroundColor: _background(context),
        actions: [
          TextButton(onPressed: controller.reset, child: const Text("Reset")),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📍 DISTANCE FILTER
                  _sectionTitle("Distance"),

                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 5, 10].map((km) {
                        final selected =
                            controller.selectedDistanceKm.value ==
                            km.toDouble();

                        return ChoiceChip(
                          label: Text("$km km"),
                          selected: selected,
                          onSelected: (_) =>
                              controller.selectedDistanceKm.value = km
                                  .toDouble(),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///  CATEGORY
                  _sectionTitle("Category"),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: categories.map((e) {
                        final selected = controller.selectedCategories.contains(
                          e,
                        );

                        return FilterChip(
                          label: Text(e),
                          selected: selected,
                          onSelected: (_) => controller.toggleItem(
                            controller.selectedCategories,
                            e,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 💰 PRICE RANGE
                  _sectionTitle("Price Range"),
                  Obx(
                    () => RangeSlider(
                      values: RangeValues(
                        controller.minPrice.value,
                        controller.maxPrice.value,
                      ),
                      min: 0,
                      max: 10000,
                      onChanged: (values) {
                        controller.minPrice.value = values.start;
                        controller.maxPrice.value = values.end;
                      },
                    ),
                  ),

                  Obx(
                    () => Text(
                      "₹${controller.minPrice.value.toInt()} - ₹${controller.maxPrice.value.toInt()}",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 📦 CONDITION
                  _sectionTitle("Condition"),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: conditions.map((e) {
                        final selected = controller.selectedConditions.contains(
                          e,
                        );

                        return ChoiceChip(
                          label: Text(e),
                          selected: selected,
                          onSelected: (_) => controller.toggleItem(
                            controller.selectedConditions,
                            e,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔄 SORT BY
                  _sectionTitle("Sort By"),
                  Obx(
                    () => Column(
                      children: sortOptions.map((e) {
                        return RadioListTile(
                          value: e,
                          groupValue: controller.selectedSort.value,
                          onChanged: (val) =>
                              controller.selectedSort.value = val!,
                          title: Text(e),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ///  APPLY BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                final homeCtrl = Get.put(HomeController());
                homeCtrl.applyFilters();
                Get.back(result: controller);
              },
              child: const Text("Apply Filters"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

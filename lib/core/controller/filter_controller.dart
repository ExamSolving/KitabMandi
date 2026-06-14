import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';

class FilterController extends GetxController {
  /// ================= DATA =================
  var categoriesData = [].obs;

  var selectedCategory = ''.obs;
  var selectedSubCategory = ''.obs;
  var selectedType = ''.obs;

  final selectedConditions = <String>[].obs;
  final selectedSort = ''.obs;

  final selectedDistanceKm = 0.0.obs;
  final minPrice = 0.0.obs;
  final maxPrice = 5000.0.obs;

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// ================= LOAD JSON =================
  Future<void> loadCategories() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/categories.json',
    );

    final data = json.decode(jsonString);
    categoriesData.value = data['categories'];
  }

  /// ================= HELPERS =================

  dynamic safeFind(List list, bool Function(dynamic) test) {
    try {
      return list.firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  List get subCategories {
    final cat = safeFind(
      categoriesData,
      (e) => e['name'] == selectedCategory.value,
    );

    return cat?['subcategories'] ?? [];
  }

  List get types {
    final sub = safeFind(
      subCategories,
      (e) => e['name'] == selectedSubCategory.value,
    );

    return sub?['children'] ?? [];
  }

  /// ================= TOGGLE =================
  void toggleItem(RxList<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  /// ================= APPLY FILTER =================
  void applyFilters() {
    final homeController = Get.find<HomeController>();
    homeController.applyAllFilters();
  }

  /// ================= RESET =================
  void reset() {
    selectedCategory.value = '';
    selectedSubCategory.value = '';
    selectedType.value = '';

    selectedConditions.clear();
    selectedSort.value = '';

    minPrice.value = 0;
    maxPrice.value = 5000;
    selectedDistanceKm.value = 0;

    final homeController = Get.find<HomeController>();

    /// 🔥 Reset search + filters together
    homeController.searchQuery.value = '';

    /// 🔥 Re-apply to refresh UI
    homeController.applyAllFilters();
  }
}

import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';

class FilterController extends GetxController {
  /// ================= SELECTED FILTERS =================
  final selectedCategories = <String>[].obs;
  final selectedConditions = <String>[].obs;

  final selectedSort = ''.obs;

  final selectedDistanceKm = 0.0.obs;

  final minPrice = 0.0.obs;
  final maxPrice = 5000.0.obs;

  /// ================= TOGGLE ITEM =================
  void toggleItem(RxList<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }

    /// refresh UI instantly
    list.refresh();
  }

  /// ================= RESET FILTERS =================
  void reset() {
    selectedCategories.clear();
    selectedConditions.clear();

    selectedSort.value = '';

    minPrice.value = 0.0;
    maxPrice.value = 5000.0;

    selectedDistanceKm.value = 0.0;

    final homeCtrl = Get.put(HomeController());

    /// default radius
    homeCtrl.radiusKm = 10.0;

    update();
  }
}

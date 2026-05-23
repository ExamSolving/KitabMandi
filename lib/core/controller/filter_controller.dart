import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';

class FilterController extends GetxController {
  var selectedCategories = <String>[].obs;
  var selectedConditions = <String>[].obs;
  var selectedSort = ''.obs;
  var selectedDistanceKm = 0.0.obs;
  var minPrice = 0.0.obs;
  var maxPrice = 5000.0.obs;

  // final homeCtrl = Get.put(HomeController());

  void toggleItem(List<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  void reset() {
    selectedCategories.clear();
    selectedConditions.clear();
    selectedSort.value = '';
    minPrice.value = 0;
    maxPrice.value = 5000;
    selectedDistanceKm.value = 0.0;
    final homeCtrl = Get.put(HomeController());
    homeCtrl.radiusKm = 10.0;
  }
}

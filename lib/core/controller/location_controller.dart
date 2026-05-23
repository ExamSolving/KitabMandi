import 'package:get/get.dart';
import '../services/location_service.dart';
import '../storage/location_storage.dart';

class LocationController extends GetxController {
  RxList<String> selectedLocations = <String>[].obs;
  RxList<String> recentLocations = <String>[].obs;

  RxBool isLoadingLocation = false.obs;

  /// 📍 Coordinates
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// 🔥 LOAD SAVED DATA
  void loadInitialData() {
    selectedLocations.value = LocationStorage.getSelected();
    recentLocations.value = LocationStorage.getRecent();

    final saved = LocationStorage.getLocationData();

    if (saved != null) {
      latitude.value = (saved['latitude'] ?? 0.0).toDouble();
      longitude.value = (saved['longitude'] ?? 0.0).toDouble();
    }

    print("📍 Loaded Location: $latitude, $longitude");
  }

  /// 📡 AUTO DETECT LOCATION
  Future<void> detectCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      final location = await LocationService.getCurrentLocationDetails();

      if (location != null) {
        final display =
            location['formatted_address'] ??
            location['city'] ??
            "Unknown Location";

        /// ✅ Update selected
        selectedLocations.value = [display];

        /// 💾 Save
        LocationStorage.saveSelected([display]);
        LocationStorage.saveLocationData(location);

        /// 📍 Assign coordinates
        latitude.value = (location['latitude'] ?? 0.0).toDouble();
        longitude.value = (location['longitude'] ?? 0.0).toDouble();

        print("📍 Detected: $latitude, $longitude");
      }
    } catch (e) {
      print("❌ Location Error: $e");
      selectedLocations.value = ["Location Error"];
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// 📍 MANUAL LOCATION (CITY SELECT)
  void updateLocation(String location) {
    if (location.isEmpty) return;

    selectedLocations.value = [location];

    /// 💾 Save selected city
    LocationStorage.saveSelected([location]);

    /// ⚠️ IMPORTANT:
    /// DO NOT reset lat/lng here
    /// Because radius filter depends on it

    print("📍 Manual Location Selected: $location");
  }

  /// 🗑 Remove recent
  void removeRecent(String location) {
    LocationStorage.removeRecent(location);
    recentLocations.value = LocationStorage.getRecent();
  }

  /// 🔄 RESET EVERYTHING
  void reset() {
    selectedLocations.clear();
    recentLocations.clear();

    latitude.value = 0.0;
    longitude.value = 0.0;

    LocationStorage.clearAll();

    print("🔄 Location Reset");
  }
}

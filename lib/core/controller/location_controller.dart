import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    recentLocations.value = LocationStorage.getRecent();
    // Only restore from cache on startup — never request permission here.
    // Permission is requested after auth (initLocation call from AuthController)
    // so the dialog appears in the right context with proper UI behind it.
    final saved = LocationStorage.getLocationData();
    final selected = LocationStorage.getSelected();
    if (saved != null && selected.isNotEmpty) {
      selectedLocations.value = selected;
      latitude.value = (saved['latitude'] ?? 0.0).toDouble();
      longitude.value = (saved['longitude'] ?? 0.0).toDouble();
    }
  }

  /// Called by AuthController after login/signup.
  /// isNewUser: true  → skip cache, always re-detect (fresh install or new account).
  /// isNewUser: false → restore cache; detect only if cache is empty.
  Future<void> initLocation({required bool isNewUser}) async {
    final saved = LocationStorage.getLocationData();
    final selected = LocationStorage.getSelected();

    if (!isNewUser && saved != null && selected.isNotEmpty) {
      // Returning user with cached location — restore and sync to Firestore.
      selectedLocations.value = selected;
      latitude.value = (saved['latitude'] ?? 0.0).toDouble();
      longitude.value = (saved['longitude'] ?? 0.0).toDouble();
      _syncLocationToFirestore(latitude.value, longitude.value);
      return;
    }

    // New user OR no cache — always auto-detect and request permission.
    await detectCurrentLocation();
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
            'Unknown Location';

        selectedLocations.value = [display];
        LocationStorage.saveSelected([display]);
        LocationStorage.saveLocationData(location);
        latitude.value = (location['latitude'] ?? 0.0).toDouble();
        longitude.value = (location['longitude'] ?? 0.0).toDouble();
        _syncLocationToFirestore(latitude.value, longitude.value);
      } else {
        // Detection returned null — check why and show actionable feedback.
        await _handleLocationFailure();
      }
    } catch (_) {
      selectedLocations.value = [];
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// Shows a snackbar explaining WHY location failed and what to do about it.
  Future<void> _handleLocationFailure() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS is Off',
          'Turn on location services so we can detect your area.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          mainButton: TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: const Text(
              'Enable',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
        return;
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Allow location access in app settings to detect your area.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 7),
          mainButton: TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text(
              'Settings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
      // If permission == denied (not forever), the OS dialog was already shown
      // by LocationService.handlePermission() and the user tapped "Deny".
      // No extra snackbar needed — the user's choice should be respected.
    } catch (_) {}
  }

  /// 📍 MANUAL LOCATION (CITY SELECT)
  void updateLocation(String location) {
    if (location.isEmpty) return;

    selectedLocations.value = [location];

    /// 💾 Save selected city
    LocationStorage.saveSelected([location]);
    recentLocations.value = LocationStorage.getRecent();

    /// ⚠️ IMPORTANT:
    /// DO NOT reset lat/lng here
    /// Because radius filter depends on it
  }

  /// 🏙 Select city from the hierarchical picker — geocodes and saves coords.
  Future<bool> selectCity({
    required String city,
    required String state,
  }) async {
    try {
      isLoadingLocation.value = true;
      final display = '$city, $state';

      final coords = await LocationService.geocodeCityName('$city, $state, India');
      if (coords != null) {
        latitude.value = coords['lat']!;
        longitude.value = coords['lng']!;
        LocationStorage.saveLocationData({
          'latitude': coords['lat'],
          'longitude': coords['lng'],
          'city': city,
          'state': state,
          'area': '',
          'locality': city,
          'district': '',
          'country': 'India',
          'pincode': '',
          'formatted_address': display,
        });
      }

      selectedLocations.value = [display];
      LocationStorage.saveSelected([display]);
      recentLocations.value = LocationStorage.getRecent();

      // Persist to Firestore so Cloud Functions can find nearby users
      _syncLocationToFirestore(latitude.value, longitude.value);
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// 🗑 Remove recent
  void removeRecent(String location) {
    LocationStorage.removeRecent(location);
    recentLocations.value = LocationStorage.getRecent();
  }

  // Writes the user's current lat/long to their Firestore profile so that
  // Cloud Functions can query nearby users when a new listing is posted.
  // Uses update() intentionally — if the document doesn't exist (deleted user),
  // Firestore throws NOT_FOUND and we silently ignore it rather than re-creating
  // a ghost document for a deleted account.
  Future<void> _syncLocationToFirestore(double lat, double long) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'location': {'lat': lat, 'long': long}});
    } catch (_) {
      // NOT_FOUND = deleted user, network error, etc. — all safe to ignore here.
    }
  }

  /// 🔄 RESET EVERYTHING
  void reset() {
    selectedLocations.clear();
    recentLocations.clear();

    latitude.value = 0.0;
    longitude.value = 0.0;

    LocationStorage.clearAll();

    debugPrint("Location reset");
  }
}

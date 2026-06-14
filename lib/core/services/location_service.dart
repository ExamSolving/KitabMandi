import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// 🔐 Check & request permission
  static Future<bool> handlePermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  ///  Get current location (lat/lng)
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await handlePermission();
      if (!hasPermission) return null;

      // Use platform-specific settings: iOS GPS cold-starts slower than Android.
      final LocationSettings settings = Platform.isIOS
          ? AppleSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 20),
            )
          : AndroidSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 10),
            );
      return await Geolocator.getCurrentPosition(locationSettings: settings);
    } catch (e) {
      return null;
    }
  }

  /// 📍 Get formatted location (OLX style)
  static Future<Map<String, dynamic>?> getCurrentLocationDetails() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      /// 🔥 Build clean JSON response
      final locationData = {
        "latitude": position.latitude,
        "longitude": position.longitude,

        "area": place.subLocality ?? "",
        "locality": place.locality ?? "",
        "city": place.locality ?? place.subAdministrativeArea ?? "",
        "district": place.subAdministrativeArea ?? "",
        "state": place.administrativeArea ?? "",
        "country": place.country ?? "",
        "pincode": place.postalCode ?? "",

        /// 🎯 formatted string (optional, useful for UI)
        "formatted_address": [
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', '),
      };

      return locationData;
    } catch (e) {
      return null;
    }
  }

  /// Geocode a city+state query to lat/lng. Returns null on failure.
  static Future<Map<String, double>?> geocodeCityName(String query) async {
    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) return null;
      return {
        'lat': results.first.latitude,
        'lng': results.first.longitude,
      };
    } catch (_) {
      return null;
    }
  }
}

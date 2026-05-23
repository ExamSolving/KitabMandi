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

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), //  prevent freeze
      );
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
}

import 'package:hive/hive.dart';

class LocationStorage {
  static const String _boxName = 'locationBox';
  static const String _selectedKey = 'selected_location';
  static const String _recentKey = 'recent_locations';

  ///  NEW KEY (FULL LOCATION JSON)
  static const String _locationDataKey = 'location_data';
  static const int _maxRecent = 10;

  static Box get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw Exception("Hive box not opened!");
    }
    return Hive.box(_boxName);
  }

  /// 📍 Save selected locations (List)
  static void saveSelected(List<String>? locations) {
    if (locations == null || locations.isEmpty) return;
    final cleanList = locations.where((e) => e.isNotEmpty).toList();
    if (cleanList.isEmpty) return;
    _box.put(_selectedKey, cleanList);

    ///  Auto add to recent
    for (final loc in cleanList) {
      addToRecent(loc);
    }
  }

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// 📍 Get selected locations
  static List<String> getSelected() {
    final data = _box.get(_selectedKey);

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// 🔥 Add to recent (no duplicates + limit)
  static void addToRecent(String location) {
    if (location.isEmpty) return;

    List<String> list = getRecent();

    list.remove(location); // ❌ remove duplicate
    list.insert(0, location); // ✅ add on top

    if (list.length > _maxRecent) {
      list = list.sublist(0, _maxRecent);
    }

    _box.put(_recentKey, list);
  }

  /// 📍 Get recent locations
  static List<String> getRecent() {
    final data = _box.get(_recentKey);

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// ❌ Remove one recent item
  static void removeRecent(String location) {
    List<String> list = getRecent();
    list.remove(location);
    _box.put(_recentKey, list);
  }

  /// 🆕 ===============================
  /// 📍 SAVE FULL LOCATION JSON
  /// ===============================
  static void saveLocationData(Map<String, dynamic> location) {
    _box.put(_locationDataKey, location);
  }

  /// 📍 GET FULL LOCATION JSON
  static Map<String, dynamic>? getLocationData() {
    final data = _box.get(_locationDataKey);

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  /// ❌ Clear only location data
  static void clearLocationData() {
    _box.delete(_locationDataKey);
  }

  /// 🧹 Clear only recent
  static void clearRecent() {
    _box.delete(_recentKey);
  }

  /// 🧹 Clear all storage
  static void clearAll() {
    _box.clear();
  }
}

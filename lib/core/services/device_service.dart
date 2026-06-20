import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive/hive.dart';

class DeviceService {
  static const _keyDeviceId = 'deviceId';
  static String? _cachedId;

  /// Returns a stable per-device identifier.
  ///
  /// iOS  → identifierForVendor (resets only on full wipe).
  /// Android → UUID persisted in settingsBox (resets on app uninstall).
  ///
  /// Always call this from an async context; the result is cached in memory
  /// so repeated calls within a session are instant.
  static Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    if (Platform.isIOS) {
      try {
        final info = await DeviceInfoPlugin().iosInfo;
        final vendor = info.identifierForVendor;
        if (vendor != null && vendor.isNotEmpty) {
          _cachedId = 'ios_$vendor';
          return _cachedId!;
        }
      } catch (_) {}
    }

    // Android + fallback: UUID persisted across account switches.
    final box = Hive.box('settingsBox');
    String? stored = box.get(_keyDeviceId) as String?;
    if (stored == null) {
      stored = _generateId();
      await box.put(_keyDeviceId, stored);
    }
    _cachedId = stored;
    return _cachedId!;
  }

  static String _generateId() {
    final rng = Random.secure();
    final bytes = List.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

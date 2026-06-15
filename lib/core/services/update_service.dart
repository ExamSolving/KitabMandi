import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const _packageId = 'com.appvora.kitabmandi';
  static const _fallbackUrl =
      'https://play.google.com/store/apps/details?id=$_packageId';

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches version config from Firestore `app_config/android` and shows
  /// an update dialog when a newer version is available.
  /// Silent no-op if the document is missing or the app is already up to date.
  static Future<void> checkForUpdate() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('android')
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final latestVersion = (data['latest_version'] as String?) ?? '';
      final minimumVersion = (data['minimum_version'] as String?) ?? '';
      final isMandatory = (data['is_mandatory'] as bool?) ?? false;
      final updateMessage = (data['update_message'] as String?) ??
          'We\'ve added new features and improvements. Update for the best experience!';
      final playStoreUrl =
          (data['play_store_url'] as String?) ?? _fallbackUrl;

      if (latestVersion.isEmpty) return;

      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      final isForce = minimumVersion.isNotEmpty &&
          _compareVersions(current, minimumVersion) < 0;
      final isOptional =
          !isForce && _compareVersions(current, latestVersion) < 0;

      if (!isForce && !isOptional) return;

      // Brief delay so the dashboard renders first
      await Future.delayed(const Duration(milliseconds: 800));

      Get.dialog(
        _UpdateDialog(
          currentVersion: current,
          latestVersion: latestVersion,
          message: updateMessage,
          isMandatory: isForce || isMandatory,
          playStoreUrl: playStoreUrl,
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      debugPrint('[UpdateService] $e');
    }
  }

  /// Opens the Play Store listing for this app.
  static Future<void> openPlayStore([String? url]) async {
    final market = Uri.parse('market://details?id=$_packageId');
    final web = Uri.parse(url ?? _fallbackUrl);
    if (await canLaunchUrl(market)) {
      await launchUrl(market);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  // Returns negative if a < b, 0 if equal, positive if a > b (semver).
  static int _compareVersions(String a, String b) {
    final pa = a.split('.').map(int.tryParse).whereType<int>().toList();
    final pb = b.split('.').map(int.tryParse).whereType<int>().toList();
    for (int i = 0; i < 3; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium update dialog
// ─────────────────────────────────────────────────────────────────────────────
class _UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String message;
  final bool isMandatory;
  final String playStoreUrl;

  const _UpdateDialog({
    required this.currentVersion,
    required this.latestVersion,
    required this.message,
    required this.isMandatory,
    required this.playStoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1F28) : Colors.white;

    return PopScope(
      canPop: !isMandatory,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        backgroundColor: cardBg,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GradientHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // Title
                  Text(
                    'update_available'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Version pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF1B5E20).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'v$currentVersion',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: theme.hintColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 13, color: const Color(0xFF2E7D32)),
                        ),
                        Text(
                          'v$latestVersion',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Update Now CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          UpdateService.openPlayStore(playStoreUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.system_update_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'update_now'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isMandatory) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'maybe_later'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'update_required_msg'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF14391A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Icon circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Icon(
              Icons.system_update_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          // Badge chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.new_releases_rounded,
                    color: Colors.white, size: 13),
                const SizedBox(width: 5),
                Text(
                  'new_version_released'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

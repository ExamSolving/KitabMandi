import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/services/fcm_service.dart';
import 'package:kitab_mandi/core/services/sold_cleanup_service.dart';
import 'package:kitab_mandi/core/services/update_service.dart';
import 'package:kitab_mandi/core/services/device_service.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/dashboard/binding/chat_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/dashboard_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/home_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/profile_binding.dart';
import 'package:kitab_mandi/features/resume/view/resume_view.dart';
import 'package:kitab_mandi/features/dashboard/view/home_view.dart';
import 'package:kitab_mandi/features/dashboard/view/profile_view.dart';
import 'package:kitab_mandi/features/dashboard/view/chat_view.dart';
import 'package:kitab_mandi/features/dashboard/widget/custom_bottom_nav.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int currentIndex = 0;

  // MUST be late — field initializers run before initState, so any
  // Get.find<>() inside the tab views would crash before bindings are called.
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // DashboardView is often rendered inline from WrapperView (the app's
    // auth-gate), which bypasses the route system and its bindings. We call
    // each binding's dependencies() here so controllers are guaranteed to be
    // registered before the tab widgets do Get.find<>().
    //
    // GetX's lazyPut is idempotent — if a controller is already registered
    // (e.g. when DashboardView IS reached via a named route), these calls are
    // no-ops.
    DashboardBinding().dependencies();
    HomeBinding().dependencies();
    ProfileBinding().dependencies();
    ChatBinding().dependencies();

    pages = [HomeView(), ChatView(), const ResumeView(), ProfileView()];

    // If the app was launched by tapping a notification while terminated,
    // navigate to the correct screen once the dashboard is fully rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService.instance.consumePendingNavigation();
      UpdateService.checkForUpdate();
      // Background cleanup: hard-delete listings sold more than 7 days ago.
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) SoldCleanupService.run(uid);
    });
  }

  void onTabChange(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onCenterTap() => _handleCenterTap();

  Future<void> _handleCenterTap() async {
    final userData = Get.find<AuthController>().userData.value;
    final sub = userData?['subscription'] as Map<String, dynamic>?;

    // Paid users have no posting restriction — go straight to form.
    if (SubscriptionService.isActive(sub)) {
      Get.toNamed(AppRoutes.addListing);
      return;
    }

    // Device-level check: catches users who switch Gmail accounts on the same
    // device to bypass the 30-day free limit.
    try {
      final deviceId = await DeviceService.getDeviceId();
      final doc = await FirebaseFirestore.instance
          .collection('device_limits')
          .doc(deviceId)
          .get();
      if (doc.exists) {
        final raw = doc.data()?['lastListingAt'];
        if (raw != null) {
          final lastAt = (raw as Timestamp).toDate();
          final elapsed = DateTime.now().difference(lastAt);
          if (elapsed.inDays < 30) {
            _showFreeLimitSheet(30 - elapsed.inDays);
            return;
          }
        }
      }
    } catch (_) {
      // If device check fails, fall through to account-level check.
    }

    // Account-level check (covers the window before device_limits is stamped).
    final raw = userData?['lastListingAt'];
    if (raw != null) {
      final lastAt = (raw as Timestamp).toDate();
      final elapsed = DateTime.now().difference(lastAt);
      if (elapsed.inDays < 30) {
        _showFreeLimitSheet(30 - elapsed.inDays);
        return;
      }
    }

    Get.toNamed(AppRoutes.addListing);
  }

  void _showFreeLimitSheet(int daysLeft) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D23);
    final subColor = isDark ? Colors.white60 : const Color(0xFF666666);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Icon
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Free Plan Limit Reached',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Free accounts can post 1 listing every 30 days.\nUpgrade to post unlimited books anytime.',
              style: TextStyle(fontSize: 14, color: subColor, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Days remaining info pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Next free listing available in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Premium perks card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.07),
                    AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Upgrade Premium & get',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _PremiumPerk(
                    icon: Icons.all_inclusive_rounded,
                    text: 'Unlimited listings — no waiting',
                  ),
                  const SizedBox(height: 8),
                  const _PremiumPerk(
                    icon: Icons.description_rounded,
                    text: 'AI Resume Builder (Plus & Pro)',
                  ),
                  const SizedBox(height: 8),
                  const _PremiumPerk(
                    icon: Icons.trending_up_rounded,
                    text: 'Priority placement in search',
                  ),
                  const SizedBox(height: 8),
                  const _PremiumPerk(
                    icon: Icons.verified_rounded,
                    text: 'Trusted Seller badge',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Upgrade CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.subscription);
                },
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: const Text(
                  'Upgrade Premium',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dismiss
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: Get.back,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  foregroundColor: subColor,
                ),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all pages alive — no reload when switching tabs.
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: onTabChange,
        onCenterTap: onCenterTap,
      ),
    );
  }
}

class _PremiumPerk extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PremiumPerk({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

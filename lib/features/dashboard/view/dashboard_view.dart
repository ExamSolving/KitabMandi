import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/services/fcm_service.dart';
import 'package:kitab_mandi/core/services/sold_cleanup_service.dart';
import 'package:kitab_mandi/core/services/update_service.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/dashboard/binding/chat_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/dashboard_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/home_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/profile_binding.dart';
import 'package:kitab_mandi/features/dashboard/view/my_ads_view.dart';
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

    pages = [HomeView(), ChatView(), MyAdsView(), ProfileView()];

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

  void onCenterTap() {
    final userData = Get.find<AuthController>().userData.value;
    final raw = userData?['lastListingAt'];
    if (raw != null) {
      final lastAt = (raw as Timestamp).toDate();
      final elapsed = DateTime.now().difference(lastAt);
      if (elapsed.inSeconds < const Duration(hours: 24).inSeconds) {
        _showDailyLimitSheet(const Duration(hours: 24) - elapsed);
        return;
      }
    }
    Get.toNamed(AppRoutes.addListing);
  }

  void _showDailyLimitSheet(Duration remaining) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
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
                  colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Daily Limit Reached',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Free accounts can post 1 listing every 24 hours.',
              style: TextStyle(
                fontSize: 14,
                color: subColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Countdown pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: Color(0xFFFF6B35),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next listing available in ${hours}h ${minutes}m',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
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
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'With Premium you get',
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
                    text: 'Unlimited listings per day',
                  ),
                  const SizedBox(height: 8),
                  const _PremiumPerk(
                    icon: Icons.trending_up_rounded,
                    text: 'Priority placement in search',
                  ),
                  const SizedBox(height: 8),
                  const _PremiumPerk(
                    icon: Icons.verified_rounded,
                    text: 'Verified seller badge',
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
                  // TODO: navigate to premium upgrade screen when available
                },
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: const Text(
                  'Upgrade to Premium — Coming Soon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
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
                  "Got it, I'll wait",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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

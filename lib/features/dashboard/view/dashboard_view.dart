import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:kitab_mandi/core/services/fcm_service.dart';
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
    });
  }

  void onTabChange(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onCenterTap() {
    Get.toNamed(AppRoutes.addListing);
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

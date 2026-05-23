import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
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

  final pages = [HomeView(), ChatView(), MyAdsView(), ProfileView()];

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
      body: pages[currentIndex],

      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: onTabChange,
        onCenterTap: onCenterTap,
      ),
    );
  }
}

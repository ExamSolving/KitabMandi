import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_filter_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_searchbar_widget.dart';

class LocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  LocationAppBar({super.key});

  final homeCtrl = Get.find<HomeController>();
  final filterCtrl = Get.find<FilterController>();

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      backgroundColor: _background(context),
      shape: Border(bottom: BorderSide(color: _border(context), width: 1)),
      titleSpacing: 12,
      // 🔝 TOP ROW (Location)
      leading: IconButton(
        onPressed: () {
          filterCtrl.reset();
          Get.back();
        },
        icon: Icon(Icons.arrow_back),
      ),
      title: Text("Listings"),

      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.notifications_none, color: theme.iconTheme.color),
      //   ),
      // ],

      // 🔥 THIS IS THE IMPORTANT PART (SEARCH BAR)
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: SearchBarWidget(
            controller: TextEditingController(),
            onChanged: (value) {
              // handle search
              homeCtrl.onSearchChanged(value);
            },
            onFilterTap: () async {
              await Get.to(() => FilterScreen());
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}

/* ===================== CITY SCREEN ===================== */

class CityScreen extends StatelessWidget {
  final String state;
  final List<String> cities;

  const CityScreen({super.key, required this.state, required this.cities});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();
    return Scaffold(
      appBar: AppBar(title: Text(state)),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (_, i) {
          final city = cities[i];
          return ListTile(
            leading: const Icon(Icons.place),
            title: Text(city),
            onTap: () {
              controller.updateLocation(city);

              /// close city screen
              Get.back();

              /// close bottom sheet
              Get.back();
            },
          );
        },
      ),
    );
  }
}

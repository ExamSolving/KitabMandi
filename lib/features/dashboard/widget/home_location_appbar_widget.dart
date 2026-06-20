import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_filter_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_searchbar_widget.dart';
import 'package:kitab_mandi/widgets/kitab_back_button.dart';
import 'package:kitab_mandi/widgets/notification_bell.dart';

class LocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  LocationAppBar({super.key});

  final homeCtrl = Get.find<HomeController>();
  final filterCtrl = Get.find<FilterController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1D23) : Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 12,
      leading: KitabBackButton(
        onTap: () {
          filterCtrl.reset();
          Get.back();
        },
      ),
      actions: const [NotificationBell(), SizedBox(width: 4)],
      title: Text(
        'Listings',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1D23),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: SearchBarWidget(
            controller: TextEditingController(),
            onChanged: (value) {
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
              Get.back();
              Get.back();
            },
          );
        },
      ),
    );
  }
}

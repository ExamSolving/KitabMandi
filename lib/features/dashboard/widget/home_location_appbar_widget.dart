import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_filter_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_searchbar_widget.dart';

class LocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LocationAppBar({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  void _openLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LocationSheet(),
    );
  }

  String _getDisplayLocation(LocationController controller) {
    if (controller.selectedLocations.isNotEmpty) {
      return controller.selectedLocations.first;
    }
    return "Select City";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<LocationController>();

    return AppBar(
      elevation: 0,
      backgroundColor: _background(context),
      shape: Border(bottom: BorderSide(color: _border(context), width: 1)),
      titleSpacing: 12,

      // 🔝 TOP ROW (Location)
      title: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),

          const SizedBox(width: 8),

          /// FIXED OVERFLOW
          Expanded(
            child: Obx(() {
              final location = _getDisplayLocation(controller);

              return GestureDetector(
                onTap: () => _openLocationSheet(context),

                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),

                    const SizedBox(width: 2),

                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: theme.iconTheme.color,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),

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
              // 🔍 handle search
              Get.put(HomeController()).onSearchChanged(value);
            },
            onFilterTap: () async {
              final result = await Get.to(() => FilterScreen());

              if (result != null) {
                print(result.selectedCategories);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}

/* ===================== LOCATION SHEET ===================== */

class _LocationSheet extends StatelessWidget {
  const _LocationSheet();

  // ///  STATIC STATES + CITIES
  // static final Map<String, List<String>> stateCities = {
  //   "Andhra Pradesh": ["Vijayawada", "Visakhapatnam", "Guntur", "Tirupati"],
  //   "Telangana": ["Hyderabad", "Warangal", "Karimnagar", "Nizamabad"],
  //   "Karnataka": ["Bangalore", "Mysore", "Mangalore", "Hubli"],
  //   "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai", "Salem"],
  //   "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
  //   "Delhi": ["New Delhi", "Dwarka", "Rohini"],
  //   "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
  //   "Rajasthan": ["Jaipur", "Udaipur", "Jodhpur", "Kota"],
  //   "Uttar Pradesh": [
  //     "Lucknow",
  //     "Noida",
  //     "Kanpur",
  //     "Varanasi",
  //     "Gorakhpur",
  //     "Kushinagar",
  //     "Padrauna",
  //   ],
  //   "Madhya Pradesh": ["Indore", "Bhopal", "Gwalior"],
  //   "West Bengal": ["Kolkata", "Howrah", "Durgapur"],
  //   "Punjab": ["Amritsar", "Ludhiana", "Jalandhar"],
  //   "Haryana": ["Gurgaon", "Faridabad", "Panipat"],
  //   "Bihar": ["Patna", "Gaya", "Muzaffarpur"],
  //   "Odisha": ["Bhubaneswar", "Cuttack", "Rourkela"],
  //   "Kerala": ["Kochi", "Trivandrum", "Kozhikode"],
  //   "Jharkhand": ["Ranchi", "Jamshedpur", "Dhanbad"],
  //   "Assam": ["Guwahati", "Silchar"],
  // };

  // List<String> get states => stateCities.keys.toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<LocationController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// HANDLE
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),

              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// 📍 CURRENT LOCATION
              Obx(() {
                return ListTile(
                  leading: controller.isLoadingLocation.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.my_location,
                          color: theme.colorScheme.primary,
                        ),
                  title: Text(
                    controller.isLoadingLocation.value
                        ? "Detecting location..."
                        : "Use current location",
                  ),
                  onTap: () async {
                    await controller.detectCurrentLocation();
                    Get.back();
                  },
                );
              }),

              const Divider(),

              ///  RECENT LOCATIONS
              Obx(() {
                if (controller.recentLocations.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Recent Locations",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...controller.recentLocations.map((loc) {
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(loc),
                        onTap: () {
                          controller.updateLocation(loc);
                          Get.back();
                        },
                      );
                    }),
                    const Divider(),
                  ],
                );
              }),

              // /// 📍 STATES LIST
              // Expanded(
              //   child: ListView.builder(
              //     controller: scrollController,
              //     itemCount: states.length,
              //     itemBuilder: (_, i) {
              //       final state = states[i];
              //       return ListTile(
              //         // leading: const Icon(Icons.map),
              //         title: Text(state),
              //         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              //         onTap: () {
              //           Get.to(
              //             () => CityScreen(
              //               state: state,
              //               cities: stateCities[state]!,
              //             ),
              //           );
              //         },
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
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

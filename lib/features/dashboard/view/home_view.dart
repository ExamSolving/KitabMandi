import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_location_appbar_widget.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final homeCtrl = Get.put(HomeController());
  final filterCtrl = Get.put(FilterController());
  final locationCtrl = Get.put(LocationController());

  final RxInt currentBanner = 0.obs;

  final List<Map<String, dynamic>> categories = [
    {
      "icon": Icons.menu_book_rounded,
      "title": "Collage",
      "subtitle": "Books",
      "color": const Color(0xFF7CFFB2),
    },
    {
      "icon": Icons.library_books_rounded,
      "title": "School",
      "subtitle": "Books",
      "color": const Color(0xFFFF8E8E),
    },
    {
      "icon": Icons.notes_rounded,
      "title": "Notes",
      "color": const Color(0xFF7DF9FF),
    },
    {
      "icon": Icons.auto_stories_rounded,
      "title": "Magazines",
      "color": const Color(0xFFFFB86B),
    },
    {
      "icon": Icons.school_rounded,
      "title": "Competitive",
      "subtitle": "Exams",
      "color": const Color(0xFFFF7AA2),
    },
  ];

  final List<String> bannerImages = [
    "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
    "https://images.unsplash.com/photo-1512820790803-83ca734da794",
    "https://images.unsplash.com/photo-1516979187457-637abb4f9353",
  ];

  double responsiveText(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1000) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
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
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width > 600;

    final bool isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF7F8FA);

    final cardColor = isDark ? const Color(0xFF171B22) : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);

    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _background(context),
        shape: Border(bottom: BorderSide(color: _border(context), width: 1)),
        titleSpacing: 12,
        title: Row(
          children: [
            Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),

            const SizedBox(width: 8),

            /// FIXED OVERFLOW
            Expanded(
              child: Obx(() {
                final location = _getDisplayLocation(locationCtrl);

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
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          filterCtrl.reset();
          homeCtrl.listenListings();
        },

        child: Obx(() {
          /// ================= LOADING =================
          if (homeCtrl.isLoading.value) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 120),

              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  height: isTablet ? 240 : 190,

                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.25)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 115,

                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,

                    itemBuilder: (_, __) {
                      return Container(
                        width: 80,

                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.25)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      );
                    },

                    separatorBuilder: (_, __) => const SizedBox(width: 16),

                    itemCount: 5,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 320,

                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,

                    itemBuilder: (_, __) => const SizedBox(
                      width: 210,
                      child: ListingGridCardShimmer(),
                    ),

                    separatorBuilder: (_, __) => const SizedBox(width: 16),

                    itemCount: 4,
                  ),
                ),
              ],
            );
          }

          /// ================= EMPTY =================
          if (homeCtrl.filteredListings.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              children: [
                SizedBox(height: Get.height * 0.3),

                Center(
                  child: Text(
                    "No listings found 😔",

                    style: theme.textTheme.titleMedium?.copyWith(
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            );
          }

          /// ================= MAIN UI =================
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),

            children: [
              const SizedBox(height: 8),

              /// ================= BANNER =================
              CarouselSlider.builder(
                itemCount: bannerImages.length,

                options: CarouselOptions(
                  height: isTablet ? 260 : 190,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: isTablet ? 0.75 : 0.92,
                  autoPlayInterval: const Duration(seconds: 4),

                  onPageChanged: (index, reason) {
                    currentBanner.value = index;
                  },
                ),

                itemBuilder: (_, index, realIndex) {
                  return Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),

                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,

                        colors: [Color(0xFFEAF8E7), Color(0xFFD8EFD3)],
                      ),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),

                      child: Stack(
                        children: [
                          /// LEFT CONTENT
                          Positioned(
                            left: 18,
                            top: 18,
                            bottom: 18,

                            child: SizedBox(
                              width: width * 0.38,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Text(
                                    "Find the right\nstudy material\nfor your success",

                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,

                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontSize: responsiveText(
                                        context,
                                        mobile: 18,
                                        tablet: 24,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      letterSpacing: -0.5,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: isTablet ? 14 : 10),

                                  Text(
                                    "Buy & Sell Books, Notes\nwith nearby students",

                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,

                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: responsiveText(
                                        context,
                                        mobile: 11,
                                        tablet: 14,
                                      ),
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// RIGHT IMAGE
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,

                            child: SizedBox(
                              width: width * 0.42,

                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(28),
                                  bottomRight: Radius.circular(28),
                                ),

                                child: Image.network(
                                  bannerImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              /// ================= DOTS =================
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: List.generate(bannerImages.length, (index) {
                    final isActive = currentBanner.value == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      margin: const EdgeInsets.symmetric(horizontal: 4),

                      height: 7,
                      width: isActive ? 12 : 7,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),

                        color: isActive
                            ? const Color(0xFF63E6A9)
                            : isDark
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              /// ================= CATEGORY HEADER =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "Top Categories",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: responsiveText(
                          context,
                          mobile: 16,
                          tablet: 24,
                        ),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: primaryText,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Get.to(() => AllCategoriesScreen());
                      },

                      child: Text(
                        "See all",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: responsiveText(
                            context,
                            mobile: 12,
                            tablet: 15,
                          ),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF63E6A9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ================= CATEGORY LIST =================
              SizedBox(
                height: isTablet ? 120 : 110,

                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),

                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,

                  separatorBuilder: (_, __) => const SizedBox(width: 10),

                  itemCount: categories.length,

                  itemBuilder: (_, index) {
                    final category = categories[index];

                    return SizedBox(
                      width: isTablet ? 96 : 78,

                      child: Column(
                        children: [
                          Container(
                            width: isTablet ? 72 : 62,
                            height: isTablet ? 72 : 62,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),

                              color: cardColor,

                              border: Border.all(color: borderColor),

                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.25)
                                      : Colors.black.withOpacity(0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: Icon(
                              category['icon'],
                              size: isTablet ? 30 : 24,
                              color: category['color'],
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            height: 34,

                            child: Column(
                              children: [
                                Text(
                                  category['title'],
                                  textAlign: TextAlign.center,
                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: responsiveText(
                                      context,
                                      mobile: 11,
                                      tablet: 12.5,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),

                                if (category['subtitle'] != null)
                                  Text(
                                    category['subtitle'],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,

                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: responsiveText(
                                        context,
                                        mobile: 11,
                                        tablet: 12.5,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: secondaryText,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              /// ================= POPULAR HEADER =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "Popular Near You",

                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: responsiveText(
                          context,
                          mobile: 16,
                          tablet: 24,
                        ),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: primaryText,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Get.to(() => AllListingsScreen());
                      },

                      child: Text(
                        "See all",

                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: responsiveText(
                            context,
                            mobile: 12,
                            tablet: 15,
                          ),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF63E6A9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ================= LISTINGS =================
              SizedBox(
                height: isTablet ? 360 : 295,

                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,

                  separatorBuilder: (_, __) => const SizedBox(width: 16),

                  itemCount: homeCtrl.filteredListings.length,

                  itemBuilder: (_, index) {
                    final book = homeCtrl.filteredListings[index];

                    return SizedBox(
                      width: isTablet ? 250 : 190,
                      child: ListingGridCard(book: book),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

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

class AllCategoriesScreen extends StatelessWidget {
  AllCategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      "icon": Icons.menu_book_rounded,
      "title": "College Books",
      "subtitle": "Engineering, BCA, B.Tech",
      "color": const Color(0xFF7CFFB2),
    },
    {
      "icon": Icons.library_books_rounded,
      "title": "School Books",
      "subtitle": "Class 1 - 12",
      "color": const Color(0xFFFF8E8E),
    },
    {
      "icon": Icons.notes_rounded,
      "title": "Notes",
      "subtitle": "Handwritten Notes",
      "color": const Color(0xFF7DF9FF),
    },
    {
      "icon": Icons.auto_stories_rounded,
      "title": "Magazines",
      "subtitle": "Monthly & Weekly",
      "color": const Color(0xFFFFB86B),
    },
    {
      "icon": Icons.school_rounded,
      "title": "Competitive Exams",
      "subtitle": "UPSC, SSC, Railway",
      "color": const Color(0xFFFF7AA2),
    },
    {
      "icon": Icons.computer_rounded,
      "title": "Programming",
      "subtitle": "Coding & Development",
      "color": const Color(0xFF9C88FF),
    },
    {
      "icon": Icons.language_rounded,
      "title": "Languages",
      "subtitle": "English, Hindi, Telugu",
      "color": const Color(0xFF4DA3FF),
    },
    {
      "icon": Icons.account_balance_rounded,
      "title": "Commerce",
      "subtitle": "Accounts & Finance",
      "color": const Color(0xFFFFC857),
    },
  ];

  double responsiveText(
    BuildContext context, {
    required double mobile,
    double? tablet,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width > 600) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  Color _appBarBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width > 600;

    final bool isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF7F8FA);

    final cardColor = isDark ? const Color(0xFF171B22) : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);

    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        elevation: 8,
        backgroundColor: _appBarBg(context),
        centerTitle: true,

        title: Text(
          "All Categories",
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w600,
            fontSize: responsiveText(context, mobile: 16, tablet: 24),
          ),
        ),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),

        physics: const BouncingScrollPhysics(),

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isTablet ? 1.18 : 1.02,
        ),

        itemCount: categories.length,

        itemBuilder: (_, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () {
              /// Navigate category wise
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius: BorderRadius.circular(24),

                border: Border.all(color: borderColor),

                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.22)
                        : Colors.black.withOpacity(0.04),

                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: isTablet ? 62 : 56,
                    height: isTablet ? 62 : 56,

                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(
                        isDark ? 0.18 : 0.14,
                      ),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Icon(
                      category['icon'],
                      size: isTablet ? 30 : 26,
                      color: category['color'],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    category['title'],

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w700,

                      fontSize: responsiveText(context, mobile: 15, tablet: 17),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    category['subtitle'],

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      height: 1.3,
                      color: secondaryText,
                      fontWeight: FontWeight.w500,

                      fontSize: responsiveText(context, mobile: 12, tablet: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AllListingsScreen extends StatelessWidget {
  AllListingsScreen({super.key});

  final homeCtrl = Get.find<HomeController>();
  final filterCtrl = Get.find<FilterController>();

  double responsiveText(
    BuildContext context, {
    required double mobile,
    double? tablet,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width > 600) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF7F8FA);

    final cardColor = isDark ? const Color(0xFF171B22) : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: LocationAppBar(),

      body: Obx(() {
        /// ================= SHIMMER =================
        if (homeCtrl.isLoading.value) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),

            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 300,
            ),

            itemCount: 6,

            itemBuilder: (_, __) {
              return _ListingShimmerCard(isDark: isDark, cardColor: cardColor);
            },
          );
        }

        return RefreshIndicator(
          color: Colors.green,
          backgroundColor: isDark ? const Color(0xFF171B22) : Colors.white,

          onRefresh: () async {
            filterCtrl.reset();

            homeCtrl.listenListings();

            await Future.delayed(const Duration(milliseconds: 1200));
          },

          child: homeCtrl.filteredListings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  children: [
                    SizedBox(height: Get.height * 0.35),

                    Center(
                      child: Text(
                        "No Listings Found 😔",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: responsiveText(
                            context,
                            mobile: 16,
                            tablet: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    int crossAxisCount = 2;

                    if (width >= 1200) {
                      crossAxisCount = 5;
                    } else if (width >= 900) {
                      crossAxisCount = 4;
                    } else if (width >= 600) {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),

                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),

                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: width >= 600 ? 320 : 300,
                      ),

                      itemCount: homeCtrl.filteredListings.length,

                      itemBuilder: (_, index) {
                        final book = homeCtrl.filteredListings[index];

                        return SizedBox(
                          width: double.infinity,
                          child: ListingGridCard(book: book),
                        );
                      },
                    );
                  },
                ),
        );
      }),
    );
  }
}

/// ================= SHIMMER CARD =================

class _ListingShimmerCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;

  const _ListingShimmerCard({required this.isDark, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,

      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,

      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// IMAGE
            Container(
              height: 170,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 12),

                  Container(height: 12, width: 120, color: Colors.white),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(height: 12, width: 70, color: Colors.white),

                      const Spacer(),

                      Container(height: 12, width: 50, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_location_appbar_widget.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final homeCtrl = Get.put(HomeController());
  final filterCtrl = Get.put(FilterController());

  final RxInt currentBanner = 0.obs;

  final List<Map<String, dynamic>> categories = [
    {
      "icon": Icons.menu_book_rounded,
      "title": "Books",
      "color": const Color(0xFF7CFFB2),
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
    {
      "icon": Icons.library_books_rounded,
      "title": "School",
      "subtitle": "Books",
      "color": const Color(0xFFFF8E8E),
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
      appBar: const LocationAppBar(),

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
                      "Categories",

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

                    Text(
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

                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: responsiveText(
                                        context,
                                        mobile: 10,
                                        tablet: 11,
                                      ),
                                      fontWeight: FontWeight.w500,
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

                    Text(
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

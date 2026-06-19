import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/core/data/india_locations.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_location_appbar_widget.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';
import 'package:kitab_mandi/widgets/notification_bell.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key}) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await rootBundle.loadString('assets/data/categories.json');
    final decoded = json.decode(data);
    categoriesData.value = decoded['categories'];
  }

  final homeCtrl = Get.find<HomeController>();
  final filterCtrl = Get.find<FilterController>();
  final locationCtrl = Get.find<LocationController>();
  final RxInt currentBanner = 0.obs;
  final RxList categoriesData = [].obs;

  IconData getIcon(String name) {
    switch (name.toLowerCase()) {
      case "book":
        return Icons.menu_book_rounded;
      case "school":
        return Icons.school_rounded;
      case "academic":
        return Icons.auto_stories_rounded;
      case "trophy":
        return Icons.workspace_premium_rounded;
      case "note":
        return Icons.sticky_note_2_rounded;
      case "pen":
        return Icons.draw_rounded;
      case "laptop":
        return Icons.laptop_mac_rounded;
      case "child":
        return Icons.auto_fix_high_rounded;
      case "magazine":
        return Icons.newspaper_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  List<Map<String, String>> get bannerList => [
    {
      "title": "banner_1".tr,
      "url": "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
    },
    {
      "title": "banner_2".tr,
      "url": "https://images.unsplash.com/photo-1512820790803-83ca734da794",
    },
    {
      "title": "banner_3".tr,
      "url": "https://images.unsplash.com/photo-1516979187457-637abb4f9353",
    },
  ];

  void _openLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LocationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sw = MediaQuery.sizeOf(context).width;
    final isTablet = sw >= 600;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0E1117) : const Color(0xFFF1F3F8);
    final appBarBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    // Responsive sizing — clamp keeps it sane on all screen sizes
    final bannerH = (sw * 0.52).clamp(170.0, 290.0);
    final catSectionH = (sw * 0.33).clamp(108.0, 148.0);
    final catIconW = (sw * 0.152).clamp(54.0, 76.0);
    final popularSectionH = (sw * 0.88).clamp(300.0, 390.0);
    final popularCardW = (sw * 0.54).clamp(180.0, 250.0);
    final hPad = (sw * 0.048).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarBg,
        titleSpacing: hPad,
        title: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Obx(
                () => GestureDetector(
                  onTap: () => _openLocationSheet(context),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          locationCtrl.selectedLocations.isEmpty
                              ? 'select_location'.tr
                              : locationCtrl.selectedLocations.join(", "),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: const [NotificationBell(), SizedBox(width: 4)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
            child: GestureDetector(
              onTap: () => Get.to(() => AllListingsScreen()),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2128) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      Icons.search_rounded,
                      color: theme.hintColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'search_hint'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () => homeCtrl.reloadAll(),
        child: Obx(() {
          if (homeCtrl.isLoading.value) {
            return _buildSkeleton(
              context,
              isDark: isDark,
              sw: sw,
              bannerH: bannerH,
              catSectionH: catSectionH,
              popularSectionH: popularSectionH,
              hPad: hPad,
            );
          }

          if (homeCtrl.hasError.value) {
            return _ErrorState(onRetry: homeCtrl.reloadAll);
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 32, top: 12),
            children: [
              // ── Banner ───────────────────────────────────────────────────
              CarouselSlider.builder(
                itemCount: bannerList.length,
                options: CarouselOptions(
                  height: bannerH,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.06,
                  viewportFraction: isTablet ? 0.74 : 0.92,
                  autoPlayCurve: Curves.easeInOutCubic,
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged: (i, _) => currentBanner.value = i,
                ),
                itemBuilder: (context2, index, realIdx) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: isDark ? 0.28 : 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Full-bleed image
                          AppCachedImageNetwork(
                            imageUrl: bannerList[index]["url"]!,
                            fit: BoxFit.cover,
                          ),

                          // Left-to-right dark overlay for text legibility
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  stops: const [0.15, 0.78],
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.72),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Bottom vignette
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.45, 1.0],
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.42),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Text content — bottom left
                          Positioned(
                            left: 18,
                            bottom: 18,
                            right: sw * 0.32,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'buy_sell_tagline'.tr,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bannerList[index]["title"]!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ── Banner dots ──────────────────────────────────────────────
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bannerList.length, (i) {
                    final active = currentBanner.value == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: active ? 20 : 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: active
                            ? theme.colorScheme.primary
                            : isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.14),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: hPad * 0.9),

              // ── Quick stats strip ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1D23)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFEEEFF3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.18 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() => Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          icon: Icons.menu_book_rounded,
                          value: '${homeCtrl.allListings.length}+',
                          label: 'Books',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.07),
                        indent: 16,
                        endIndent: 16,
                      ),
                      Expanded(
                        child: _StatPill(
                          icon: Icons.local_offer_rounded,
                          value: 'FREE',
                          label: 'Listing',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.07),
                        indent: 16,
                        endIndent: 16,
                      ),
                      Expanded(
                        child: _StatPill(
                          icon: Icons.handshake_rounded,
                          value: '100%',
                          label: 'Trusted',
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  )),
                ),
              ),

              SizedBox(height: hPad),

              // ── Categories header ────────────────────────────────────────
              _SectionHeader(
                title: 'top_categories'.tr,
                onSeeAll: () => Get.to(() => AllCategoriesScreen()),
                hPad: hPad,
              ),

              SizedBox(height: hPad * 0.75),

              // ── Category list — sorted by popularity ─────────────────
              Obx(() {
                if (categoriesData.isEmpty) return const SizedBox();

                // Compute popularity scores from fetched listings (reactive —
                // allListings is RxList, so this Obx rebuilds when it changes)
                final scores = homeCtrl.categoryPopularityScores();
                // final counts = homeCtrl.categoryListingCounts();

                // Build index list sorted by descending score; ties keep
                // JSON order (stable because List.sort is stable in Dart).
                final sortedIndices =
                    List.generate(categoriesData.length, (i) => i)..sort((
                      a,
                      b,
                    ) {
                      final nameA = categoriesData[a]['name'] as String? ?? '';
                      final nameB = categoriesData[b]['name'] as String? ?? '';
                      return (scores[nameB] ?? 0).compareTo(scores[nameA] ?? 0);
                    });

                return SizedBox(
                  height: catSectionH,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemCount: sortedIndices.length.clamp(0, 8),
                    itemBuilder: (_, listIndex) {
                      // originalIndex preserves correct tab in AllCategoriesScreen
                      final originalIndex = sortedIndices[listIndex];
                      final cat = categoriesData[originalIndex];
                      final catName = cat['name'] as String? ?? '';
                      // final count = counts[catName] ?? 0;

                      return GestureDetector(
                        onTap: () => Get.to(
                          () =>
                              AllCategoriesScreen(initialIndex: originalIndex),
                        ),
                        child: SizedBox(
                          width: catIconW + 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon container
                              Container(
                                width: catIconW,
                                height: catIconW,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                            .withValues(alpha: 0.14)
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(
                                              alpha: isDark ? 0.14 : 0.10),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Icon(
                                  getIcon(cat['icon']),
                                  size: catIconW * 0.44,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.primary,
                                ),
                              ),
                              SizedBox(height: catSectionH * 0.08),
                              // Category name
                              Text(
                                catName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: (sw * 0.028).clamp(10.0, 12.0),
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.80),
                                  height: 1.25,
                                ),
                              ),
                              // Listing count badge — only when > 0
                              // if (count > 0) ...[
                              //   const SizedBox(height: 3),
                              //   Text(
                              //     '$count',
                              //     style: TextStyle(
                              //       fontSize: 10,
                              //       fontWeight: FontWeight.w700,
                              //       color: theme.colorScheme.primary
                              //           .withValues(alpha: 0.75),
                              //     ),
                              //   ),
                              // ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

              SizedBox(height: hPad + 2),

              // ── Popular near you header ───────────────────────────────────
              _SectionHeader(
                title: 'popular_near_you'.tr,
                onSeeAll: () => Get.to(() => AllListingsScreen()),
                hPad: hPad,
              ),

              SizedBox(height: hPad * 0.65),

              // ── Popular listings ─────────────────────────────────────────
              SizedBox(
                height: popularSectionH,
                child: Obx(() {
                  if (locationCtrl.isLoadingLocation.value) {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (_, _) => SizedBox(
                        width: popularCardW,
                        child: const ListingGridCardShimmer(),
                      ),
                    );
                  }

                  if (locationCtrl.latitude.value == 0.0 ||
                      locationCtrl.longitude.value == 0.0) {
                    return _EmptyState(
                      icon: Icons.location_off_rounded,
                      title: 'location_not_detected'.tr,
                      action: TextButton.icon(
                        onPressed: () => locationCtrl.detectCurrentLocation(),
                        icon: const Icon(Icons.my_location_rounded, size: 16),
                        label: Text('detect_location'.tr),
                      ),
                    );
                  }

                  if (homeCtrl.popularListingNearYou.isEmpty) {
                    return _EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'no_items_nearby'.tr,
                      subtitle: 'try_change_location'.tr,
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemCount: homeCtrl.popularListingNearYou.length,
                    itemBuilder: (_, index) {
                      final book = homeCtrl.popularListingNearYou[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 280 + index * 70),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (_, v, child) => Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(28 * (1 - v), 0),
                            child: child,
                          ),
                        ),
                        child: SizedBox(
                          width: popularCardW,
                          child: ListingGridCard(listingModel: book),
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: hPad * 0.5),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSkeleton(
    BuildContext context, {
    required bool isDark,
    required double sw,
    required double bannerH,
    required double catSectionH,
    required double popularSectionH,
    required double hPad,
  }) {
    final cardColor = isDark ? const Color(0xFF171B22) : Colors.white;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    Widget shimBox(double w, double h, {double r = 12}) => Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(r),
        ),
      ),
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 32),
      children: [
        shimBox(double.infinity, bannerH, r: 22),
        const SizedBox(height: 12),
        // dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            shimBox(20, 5, r: 50),
            const SizedBox(width: 6),
            shimBox(5, 5, r: 50),
            const SizedBox(width: 6),
            shimBox(5, 5, r: 50),
          ],
        ),
        SizedBox(height: hPad * 0.9),
        // stats strip
        shimBox(double.infinity, 72, r: 18),
        SizedBox(height: hPad),
        Row(
          children: [
            shimBox(sw * 0.35, 18, r: 6),
            const Spacer(),
            shimBox(50, 14, r: 6),
          ],
        ),
        SizedBox(height: hPad * 0.65),
        SizedBox(
          height: catSectionH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) {
              final iconW = (sw * 0.152).clamp(54.0, 76.0);
              return Column(
                children: [
                  shimBox(iconW, iconW, r: iconW / 2),
                  const SizedBox(height: 9),
                  shimBox(iconW - 12, 12, r: 4),
                ],
              );
            },
          ),
        ),
        SizedBox(height: hPad + 2),
        Row(
          children: [
            shimBox(sw * 0.38, 18, r: 6),
            const Spacer(),
            shimBox(50, 14, r: 6),
          ],
        ),
        SizedBox(height: hPad * 0.65),
        SizedBox(
          height: popularSectionH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, _) => SizedBox(
              width: (sw * 0.54).clamp(180.0, 250.0),
              child: const ListingGridCardShimmer(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick stat pill ───────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Reusable section header ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final double hPad;

  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'see_all'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state with retry ────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.error.withValues(alpha: 0.10),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'error_loading_listings'.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'error_loading_subtitle'.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('try_again'.tr),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Premium empty state ──────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget action;

  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Icon(icon, size: 28, color: theme.hintColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
          action,
        ],
      ),
    );
  }
}

// ── Location sheet ─────────────────────────────────────────────────────────────
class _LocationSheet extends StatefulWidget {
  const _LocationSheet();

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet>
    with SingleTickerProviderStateMixin {
  final _ctrl = Get.find<LocationController>();
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _activeState; // null = root; set = browsing that state's cities
  bool _geocoding = false;

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _searchCtrl.addListener(() {
      if (mounted) setState(() => _query = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _openState(String state) {
    HapticFeedback.selectionClick();
    _anim.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _activeState = state;
        _query = '';
        _searchCtrl.clear();
      });
      _anim.forward();
    });
  }

  void _backToRoot() {
    HapticFeedback.selectionClick();
    _anim.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _activeState = null;
        _query = '';
        _searchCtrl.clear();
      });
      _anim.forward();
    });
  }

  // ── Selection actions ─────────────────────────────────────────────────────

  Future<void> _pickCity(String city, String state) async {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _geocoding = true);
    await _ctrl.selectCity(city: city, state: state);
    if (mounted) {
      setState(() => _geocoding = false);
      Get.back();
    }
  }

  Future<void> _pickRecent(String recent) async {
    HapticFeedback.selectionClick();
    final parts = recent.split(', ');
    if (parts.length >= 2) {
      final city = parts.sublist(0, parts.length - 1).join(', ');
      final state = parts.last;
      await _pickCity(city, state);
    } else {
      _ctrl.updateLocation(recent);
      Get.back();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final primary = theme.colorScheme.primary;
    final hint = theme.hintColor;
    final onSurface = theme.colorScheme.onSurface;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 32,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: hint.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ── Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 2, 8, 0),
                child: Row(
                  children: [
                    if (_activeState != null)
                      IconButton(
                        onPressed: _backToRoot,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: onSurface,
                        ),
                      )
                    else
                      const SizedBox(width: 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Align(
                          key: ValueKey(_activeState ?? '__root__'),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _activeState ?? 'Select Location',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(Icons.close_rounded, color: hint),
                    ),
                  ],
                ),
              ),

              // ── Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _query.isNotEmpty
                          ? primary.withValues(alpha: 0.45)
                          : Colors.transparent,
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(fontSize: 14, color: onSurface),
                    decoration: InputDecoration(
                      hintText: _activeState != null
                          ? 'Search city in $_activeState...'
                          : 'Search state or city...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: hint.withValues(alpha: 0.65),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: _query.isNotEmpty ? primary : hint,
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: hint,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // ── Geocoding progress bar
              if (_geocoding)
                LinearProgressIndicator(
                  color: primary,
                  backgroundColor: primary.withValues(alpha: 0.08),
                  minHeight: 2,
                ),

              const Divider(height: 1),

              // ── Content
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _activeState != null
                        ? _CitiesView(
                            key: ValueKey(_activeState),
                            state: _activeState!,
                            query: _query,
                            geocoding: _geocoding,
                            primary: primary,
                            hint: hint,
                            onCityTap: _pickCity,
                            scrollCtrl: scrollCtrl,
                          )
                        : _LocationRootView(
                            key: const ValueKey('__root__'),
                            query: _query,
                            locationCtrl: _ctrl,
                            primary: primary,
                            hint: hint,
                            isDark: isDark,
                            onSurface: onSurface,
                            geocoding: _geocoding,
                            onStateTap: _openState,
                            onRecentTap: _pickRecent,
                            onCityTap: _pickCity,
                            scrollCtrl: scrollCtrl,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Root view ─────────────────────────────────────────────────────────────────
class _LocationRootView extends StatelessWidget {
  final String query;
  final LocationController locationCtrl;
  final Color primary;
  final Color hint;
  final Color onSurface;
  final bool isDark;
  final bool geocoding;
  final void Function(String state) onStateTap;
  final Future<void> Function(String loc) onRecentTap;
  final Future<void> Function(String city, String state) onCityTap;
  final ScrollController scrollCtrl;

  const _LocationRootView({
    super.key,
    required this.query,
    required this.locationCtrl,
    required this.primary,
    required this.hint,
    required this.isDark,
    required this.onSurface,
    required this.geocoding,
    required this.onStateTap,
    required this.onRecentTap,
    required this.onCityTap,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    // Search mode — show cross-state results
    if (query.isNotEmpty) {
      return _SearchResults(
        query: query,
        primary: primary,
        hint: hint,
        onSurface: onSurface,
        onCityTap: onCityTap,
        scrollCtrl: scrollCtrl,
      );
    }

    final states = indianStates;

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // GPS button
        Obx(
          () => _GpsTile(
            isLoading: locationCtrl.isLoadingLocation.value,
            primary: primary,
            isDark: isDark,
            onTap: () async {
              await locationCtrl.detectCurrentLocation();
              Get.back();
            },
          ),
        ),

        // Saved / recent locations
        Obx(() {
          final recents = locationCtrl.recentLocations;
          if (recents.isEmpty) return const SizedBox();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LocSectionLabel(label: 'SAVED LOCATIONS', hint: hint),
              ...recents.map(
                (loc) => _RecentTile(
                  location: loc,
                  primary: primary,
                  hint: hint,
                  isDark: isDark,
                  onTap: () => onRecentTap(loc),
                  onDelete: () => locationCtrl.removeRecent(loc),
                ),
              ),
              const SizedBox(height: 4),
            ],
          );
        }),

        _LocSectionLabel(label: 'BROWSE BY STATE', hint: hint),
        ...states.map(
          (s) => _StateTile(
            state: s,
            primary: primary,
            hint: hint,
            onTap: () => onStateTap(s),
          ),
        ),
      ],
    );
  }
}

// ── Cities view ───────────────────────────────────────────────────────────────
class _CitiesView extends StatelessWidget {
  final String state;
  final String query;
  final bool geocoding;
  final Color primary;
  final Color hint;
  final Future<void> Function(String city, String state) onCityTap;
  final ScrollController scrollCtrl;

  const _CitiesView({
    super.key,
    required this.state,
    required this.query,
    required this.geocoding,
    required this.primary,
    required this.hint,
    required this.onCityTap,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final all = indianCitiesByState[state] ?? [];
    final cities = query.isEmpty
        ? all
        : all
              .where((c) => c.toLowerCase().contains(query.toLowerCase()))
              .toList();

    if (cities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No city found for "$query"',
            style: TextStyle(color: hint, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: cities.length,
      itemBuilder: (_, i) => _CityTile(
        city: cities[i],
        state: state,
        primary: primary,
        hint: hint,
        loading: geocoding,
        onTap: () => onCityTap(cities[i], state),
      ),
    );
  }
}

// ── Search results view ───────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final String query;
  final Color primary;
  final Color hint;
  final Color onSurface;
  final Future<void> Function(String city, String state) onCityTap;
  final ScrollController scrollCtrl;

  const _SearchResults({
    required this.query,
    required this.primary,
    required this.hint,
    required this.onSurface,
    required this.onCityTap,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final results = searchAllLocations(query);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 52,
                color: hint.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 14),
              Text(
                'No results for "$query"',
                style: TextStyle(
                  color: hint,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different city or state name',
                style: TextStyle(
                  color: hint.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_city_rounded, size: 16, color: primary),
          ),
          title: _HighlightText(
            text: r.city,
            query: query,
            primary: primary,
            onSurface: onSurface,
          ),
          subtitle: Text(r.state, style: TextStyle(fontSize: 12, color: hint)),
          onTap: () => onCityTap(r.city, r.state),
        );
      },
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _GpsTile extends StatelessWidget {
  final bool isLoading;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  const _GpsTile({
    required this.isLoading,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Material(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Gradient icon circle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withValues(alpha: 0.65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.32),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading
                            ? 'Detecting location...'
                            : 'Use Current Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Auto-detect via GPS',
                        style: TextStyle(
                          fontSize: 12,
                          color: primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLoading)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: primary.withValues(alpha: 0.45),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocSectionLabel extends StatelessWidget {
  final String label;
  final Color hint;

  const _LocSectionLabel({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: hint,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final String location;
  final Color primary;
  final Color hint;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecentTile({
    required this.location,
    required this.primary,
    required this.hint,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF4F4F4),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.history_rounded, size: 16, color: hint),
      ),
      title: Text(
        location,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: onDelete,
        icon: Icon(
          Icons.close_rounded,
          size: 15,
          color: hint.withValues(alpha: 0.55),
        ),
        tooltip: 'Remove',
      ),
      onTap: onTap,
    );
  }
}

class _StateTile extends StatelessWidget {
  final String state;
  final Color primary;
  final Color hint;
  final VoidCallback onTap;

  const _StateTile({
    required this.state,
    required this.primary,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = indianCitiesByState[state]?.length ?? 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.map_outlined, size: 16, color: primary),
      ),
      title: Text(
        state,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '$count cities',
        style: TextStyle(fontSize: 11.5, color: hint),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: hint.withValues(alpha: 0.45),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _CityTile extends StatelessWidget {
  final String city;
  final String state;
  final Color primary;
  final Color hint;
  final bool loading;
  final VoidCallback onTap;

  const _CityTile({
    required this.city,
    required this.state,
    required this.primary,
    required this.hint,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.location_city_rounded, size: 16, color: primary),
      ),
      title: Text(
        city,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(state, style: TextStyle(fontSize: 11.5, color: hint)),
      trailing: loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: primary),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: hint.withValues(alpha: 0.45),
              size: 20,
            ),
      onTap: loading ? null : onTap,
    );
  }
}

/// Bolds the matching portion of text in the primary color.
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final Color primary;
  final Color onSurface;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.primary,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final idx = text.toLowerCase().indexOf(query.toLowerCase());
    if (idx < 0 || query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: TextStyle(color: primary, fontWeight: FontWeight.w700),
          ),
          if (idx + query.length < text.length)
            TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}

// ── All Categories ────────────────────────────────────────────────────────────
class AllCategoriesScreen extends StatefulWidget {
  final int initialIndex;
  const AllCategoriesScreen({super.key, this.initialIndex = 0});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  List _cats = [];
  bool _loading = true;
  final ScrollController _leftScroll = ScrollController();
  final filterCtrl = Get.find<FilterController>();
  final homeCtrl = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _leftScroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/categories.json');
    final loaded = (json.decode(raw)['categories'] as List);
    final idx = widget.initialIndex.clamp(0, loaded.length - 1);

    // Always force-select the tapped category — fixes the "not selected" bug
    final target = loaded[idx];
    filterCtrl.selectedCategory.value = target['name'] as String;
    final subs = (target['subcategories'] as List?) ?? [];
    // Auto-select first sub so its chip is highlighted immediately
    filterCtrl.selectedSubCategory.value = subs.isNotEmpty
        ? (subs[0]['name'] as String)
        : '';
    filterCtrl.selectedType.value = '';

    if (mounted) {
      setState(() {
        _cats = loaded;
        _loading = false;
      });
    }
  }

  IconData _icon(String key) {
    switch (key.toLowerCase()) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'academic':
        return Icons.auto_stories_rounded;
      case 'trophy':
        return Icons.workspace_premium_rounded;
      case 'note':
        return Icons.sticky_note_2_rounded;
      case 'pen':
        return Icons.draw_rounded;
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'child':
        return Icons.auto_fix_high_rounded;
      case 'magazine':
        return Icons.newspaper_rounded;
      case 'exam':
        return Icons.fact_check_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'engineering':
        return Icons.engineering_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  int _mainIdx() {
    final i = _cats.indexWhere(
      (c) => c['name'] == filterCtrl.selectedCategory.value,
    );
    return i < 0 ? 0 : i;
  }

  void _selectMain(dynamic item) {
    final subs = (item['subcategories'] as List?) ?? [];
    filterCtrl.selectedCategory.value = item['name'] as String;
    // Auto-select first sub so chips update instantly
    filterCtrl.selectedSubCategory.value = subs.isNotEmpty
        ? (subs[0]['name'] as String)
        : '';
    filterCtrl.selectedType.value = '';
    if (subs.isEmpty) _navigate();
  }

  void _selectSub(dynamic sub) {
    filterCtrl.selectedSubCategory.value = sub['name'] as String;
    filterCtrl.selectedType.value = '';
    final kids = (sub['children'] as List?) ?? [];
    if (kids.isEmpty) _navigate();
  }

  void _selectChild(String name) {
    filterCtrl.selectedType.value = name;
    _navigate();
  }

  void _navigate() {
    homeCtrl.applyAllFilters();
    Get.to(() => AllListingsScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sw = MediaQuery.sizeOf(context).width;
    // Left panel: narrow enough to leave space for content
    final leftW = (sw * 0.215).clamp(68.0, 90.0);
    final leftBg = isDark ? const Color(0xFF13161B) : const Color(0xFFF0F1F5);
    final rightBg = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    final chipBg = isDark ? const Color(0xFF1E2128) : Colors.white;
    final chipBorder = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: rightBg,
      appBar: AppBar(
        title: Text(
          'categories'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1D23) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.dividerColor),
        ),
      ),
      body: Obx(() {
        final mainIdx = _mainIdx();
        final main = _cats[mainIdx];
        final subs = (main['subcategories'] as List?) ?? [];
        final subIdx = subs.isEmpty
            ? 0
            : subs.indexWhere(
                (s) => s['name'] == filterCtrl.selectedSubCategory.value,
              );
        final resolvedSubIdx = subIdx < 0 ? 0 : subIdx;
        final selSub = subs.isNotEmpty ? subs[resolvedSubIdx] : null;
        final children = (selSub?['children'] as List?) ?? [];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left panel ──────────────────────────────────────────────
            SizedBox(
              width: leftW,
              child: Container(
                color: leftBg,
                child: ListView.builder(
                  controller: _leftScroll,
                  itemCount: _cats.length,
                  itemBuilder: (_, i) {
                    final item = _cats[i];
                    final sel =
                        filterCtrl.selectedCategory.value == item['name'];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectMain(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: sel
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _icon(item['icon'] ?? ''),
                              size: 20,
                              color: sel
                                  ? theme.colorScheme.primary
                                  : theme.hintColor,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item['name'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: sel
                                    ? theme.colorScheme.primary
                                    : theme.hintColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Divider
            VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),

            // ── Right panel ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-category pills
                  if (subs.isNotEmpty) ...[
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemCount: subs.length,
                        itemBuilder: (_, i) {
                          final sub = subs[i];
                          final sel =
                              filterCtrl.selectedSubCategory.value ==
                              sub['name'];
                          return GestureDetector(
                            onTap: () => _selectSub(sub),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: sel ? theme.colorScheme.primary : chipBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel
                                      ? theme.colorScheme.primary
                                      : chipBorder,
                                ),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                sub['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: sel ? Colors.white : theme.hintColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: theme.dividerColor),
                  ],

                  // Children — Wrap so long labels never clip
                  Expanded(
                    child: children.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 36,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'select_subcategory'.tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: children.map((item) {
                                final name = item['name'] as String;
                                final sel =
                                    filterCtrl.selectedType.value == name;
                                return GestureDetector(
                                  onTap: () => _selectChild(name),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? theme.colorScheme.primary
                                          : chipBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: sel
                                            ? theme.colorScheme.primary
                                            : chipBorder,
                                      ),
                                      boxShadow: sel
                                          ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? Colors.white
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── All Listings ──────────────────────────────────────────────────────────────
class AllListingsScreen extends StatelessWidget {
  AllListingsScreen({super.key});

  final homeCtrl = Get.find<HomeController>();
  final filterCtrl = Get.find<FilterController>();
  final locationCtrl = Get.find<LocationController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    final cardColor = isDark ? const Color(0xFF171B22) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: LocationAppBar(),
      body: Obx(() {
        if (homeCtrl.isLoading.value) {
          return Column(
            children: [
              _LocationRadiusStrip(
                homeCtrl: homeCtrl,
                filterCtrl: filterCtrl,
                locationCtrl: locationCtrl,
                isDark: isDark,
                theme: theme,
              ),
              Expanded(
                child: GridView.builder(
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
                  itemBuilder: (_, _) =>
                      _ListingShimmerCard(isDark: isDark, cardColor: cardColor),
                ),
              ),
            ],
          );
        }

        if (homeCtrl.hasError.value) {
          return _ErrorState(onRetry: homeCtrl.reloadAll);
        }

        return Column(
          children: [
            // ── Location + radius strip ──────────────────────────────
            _LocationRadiusStrip(
              homeCtrl: homeCtrl,
              filterCtrl: filterCtrl,
              locationCtrl: locationCtrl,
              isDark: isDark,
              theme: theme,
            ),
            // ── Listings grid with pull-to-refresh ───────────────────
            Expanded(
              child: RefreshIndicator(
                color: theme.colorScheme.primary,
                backgroundColor: cardColor,
                onRefresh: () => homeCtrl.reloadAll(),
                child: Obx(() {
                  if (homeCtrl.filteredListings.isEmpty) {
                    final noListingsAtAll = homeCtrl.allListings.isEmpty;
                    final radius = homeCtrl.effectiveRadiusKm();
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: Get.height * 0.24),
                        Center(
                          child: _EmptyState(
                            icon: noListingsAtAll
                                ? Icons.storefront_outlined
                                : Icons.search_off_rounded,
                            title: noListingsAtAll
                                ? 'be_first_to_list'.tr
                                : 'no_listings_found'.tr,
                            subtitle: noListingsAtAll
                                ? 'be_first_subtitle'.tr
                                : radius != null
                                ? 'No results within ${radius.toInt()} km. Try expanding the radius in filters.'
                                : null,
                          ),
                        ),
                      ],
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final cols = w >= 1200
                          ? 5
                          : w >= 900
                          ? 4
                          : w >= 600
                          ? 3
                          : 2;
                      final extent = w >= 600 ? 320.0 : 300.0;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: extent,
                        ),
                        itemCount: homeCtrl.filteredListings.length,
                        itemBuilder: (_, index) {
                          final book = homeCtrl.filteredListings[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 240 + (index % 6) * 55,
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (_, v, child) => Opacity(
                              opacity: v,
                              child: Transform.translate(
                                offset: Offset(0, 18 * (1 - v)),
                                child: child,
                              ),
                            ),
                            child: ListingGridCard(listingModel: book),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Location radius strip ─────────────────────────────────────────────────────
class _LocationRadiusStrip extends StatelessWidget {
  final HomeController homeCtrl;
  final FilterController filterCtrl;
  final LocationController locationCtrl;
  final bool isDark;
  final ThemeData theme;

  const _LocationRadiusStrip({
    required this.homeCtrl,
    required this.filterCtrl,
    required this.locationCtrl,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Obx(() {
      final hasLocation =
          locationCtrl.latitude.value != 0.0 &&
          locationCtrl.longitude.value != 0.0;
      final distanceSetting = filterCtrl.selectedDistanceKm.value;
      final count = homeCtrl.filteredListings.length;
      final locationName = locationCtrl.selectedLocations.isNotEmpty
          ? locationCtrl.selectedLocations.first
          : '';

      // Build the radius label
      String radiusLabel;
      IconData radiusIcon;
      if (!hasLocation || distanceSetting == -1.0) {
        radiusLabel = 'All listings';
        radiusIcon = Icons.public_rounded;
      } else {
        final km = (distanceSetting > 0 ? distanceSetting : 5.0).toInt();
        radiusLabel = 'Within $km km';
        radiusIcon = Icons.location_on_rounded;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D23) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.07),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(radiusIcon, size: 14, color: primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  children: [
                    TextSpan(
                      text: radiusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    if (locationName.isNotEmpty)
                      TextSpan(text: ' · $locationName'),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Result count pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count ${count == 1 ? 'listing' : 'listings'}',
                style: TextStyle(
                  fontSize: 11,
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Shimmer card ──────────────────────────────────────────────────────────────
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
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(height: 11, width: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(height: 11, width: 60, color: Colors.white),
                      const Spacer(),
                      Container(height: 11, width: 44, color: Colors.white),
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

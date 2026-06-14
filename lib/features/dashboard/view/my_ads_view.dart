import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/widgets/notification_bell.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/dashboard/widget/my_ads_shimmer.dart';
import 'package:kitab_mandi/features/listing_details/binding/listing_details_binding.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class MyAdsView extends StatelessWidget {
  MyAdsView({super.key});

  final controller = Get.find<MyAdsController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('my_ads'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarBg,
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const MyAdsShimmer();

        if (controller.hasError.value) {
          return _MyAdsErrorState(onRetry: controller.fetchMyAds);
        }

        if (controller.myAdsList.isEmpty) return _EmptyState();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchMyAds(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: controller.myAdsList.length,
            itemBuilder: (context, index) {
              final ad = controller.myAdsList[index];
              return _AdCard(ad: ad, controller: controller, index: index);
            },
          ),
        );
      }),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _MyAdsErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _MyAdsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              child: Icon(Icons.cloud_off_rounded,
                  size: 32, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            Text(
              'error_loading_listings'.tr,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'error_loading_subtitle'.tr,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('try_again'.tr),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2430) : const Color(0xFFF0F4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront_outlined,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          Text('no_ads_yet'.tr,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('start_selling'.tr,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}

// ── Ad card ───────────────────────────────────────────────────────────────────
class _AdCard extends StatelessWidget {
  final ListingModel ad;
  final MyAdsController controller;
  final int index;

  const _AdCard({
    required this.ad,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSold = ad.isSold == true;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + index * 60),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => Get.to(
          () => ListingDetailsView(listing: ad, docId: ad.id),
          binding: ListingDetailsBinding(),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Thumbnail ────────────────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    AppCachedImageNetwork(
                      height: 110,
                      width: 110,
                      imageUrl: ad.images.isNotEmpty ? ad.images[0] : '',
                      fit: BoxFit.cover,
                    ),
                    if (isSold)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: Center(
                            child: Text(
                              'sold'.tr.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Details ──────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '₹ ${ad.price}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSold
                              ? Colors.red.withValues(alpha: 0.12)
                              : Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSold ? Colors.red : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isSold ? 'sold'.tr : 'active'.tr,
                              style: TextStyle(
                                color: isSold ? Colors.red : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            '${ad.views} ${'views'.tr}',
                            style: TextStyle(
                                fontSize: 11, color: theme.hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded,
                    color: theme.hintColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

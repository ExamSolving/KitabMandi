import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/dashboard/widget/my_ads_shimmer.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class MyAdsView extends StatelessWidget {
  MyAdsView({super.key});
  final controller = Get.put(MyAdsController());
  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Ads"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _background(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const MyAdsShimmer();
        }

        if (controller.myAdsList.isEmpty) {
          return _emptyState(context);
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchMyAds(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.myAdsList.length,
            itemBuilder: (context, index) {
              final ad = controller.myAdsList[index];
              return _adCard(ad, controller, context, isDark);
            },
          ),
        );
      }),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            "No Ads Yet",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Start selling your books now!",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ================= AD CARD =================
  Widget _adCard(
    ListingModel ad,
    MyAdsController controller,
    BuildContext context,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(ListingDetailsView(listing: ad, docId: ad.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // 📸 IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: AppCachedImageNetwork(
                height: 100,
                width: 100,
                imageUrl: ad.images[0],
              ),
            ),

            // 📄 DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      ad.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Text(
                      "₹ ${ad.price}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status
                    Row(
                      children: [
                        Icon(
                          ad.isSold == true
                              ? Icons.check_circle
                              : Icons.radio_button_checked,
                          size: 14,
                          color: ad.isSold == true ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ad.isSold == true ? "Sold" : "Active",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ad.isSold == true
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ACTION BUTTONS
                    // Row(
                    //   children: [
                    //     _actionButton(
                    //       context: context,
                    //       icon: Icons.edit,
                    //       label: "Edit",
                    //       color: AppColors.primary,
                    //       onTap: () => controller.editAd(ad),
                    //     ),
                    //     const SizedBox(width: 8),
                    //     _actionButton(
                    //       context: context,
                    //       icon: Icons.delete,
                    //       label: "Delete",
                    //       color: AppColors.secondary,
                    //       onTap: () => controller.confirmDelete(ad),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

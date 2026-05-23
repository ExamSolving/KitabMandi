import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';
import 'package:kitab_mandi/features/wishlist/controller/wishlist_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';

class WishlistView extends GetView<WishlistController> {
  WishlistView({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Wishlist", style: AppTextStyles.heading2(context)),
        elevation: 0,
        backgroundColor: _background(context),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchWishlist(); // ✅ FIX
        },

        child: Obx(() {
          /// 🔥 LOADING
          if (controller.isLoading.value) {
            return MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 6,
              itemBuilder: (_, __) => const ListingGridCardShimmer(),
            );
          }

          /// ❌ EMPTY
          if (controller.wishlist.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(), // ✅ required
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight, // 👈 full screen height
                      ),
                      child: const Center(
                        child: Text(
                          "No Favourite items found 😔",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          ///  DATA
          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.wishlist.length,
            itemBuilder: (context, index) {
              final item = controller.wishlist[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListingGridCard(
                  book: ListingModel.fromMap(item), // 👈 IMPORTANT
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

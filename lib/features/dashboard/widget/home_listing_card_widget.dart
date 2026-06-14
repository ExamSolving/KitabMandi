import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/utils/time_ago_utils.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/listing_details/binding/listing_details_binding.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/features/wishlist/controller/wishlist_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class ListingGridCard extends StatefulWidget {
  final ListingModel listingModel;

  const ListingGridCard({super.key, required this.listingModel});

  @override
  State<ListingGridCard> createState() => _ListingGridCardState();
}

class _ListingGridCardState extends State<ListingGridCard> {
  bool isFav = false;
  int currentImage = 0;
  final wishlistController = Get.find<WishlistController>();
  final homeCtrl = Get.find<HomeController>();

  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : Colors.white;
  }

  String formatViews(int views) {
    if (views >= 1000000) {
      return "${(views / 1000000).toStringAsFixed(1)}M";
    } else if (views >= 1000) {
      return "${(views / 1000).toStringAsFixed(1)}K";
    } else {
      return views.toString();
    }
  }

  String getDisplayLocation(Map<String, dynamic> location) {
    final subLocality = location['subLocality'] ?? "";
    final locality = location['locality'] ?? "";
    final city = location['city'] ?? "";

    if (subLocality.isNotEmpty && locality.isNotEmpty) {
      return "$subLocality, $locality";
    } else if (locality.isNotEmpty) {
      return locality;
    } else {
      return city;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Get.to(
            () => ListingDetailsView(
              listing: widget.listingModel,
              docId: widget.listingModel.id,
            ),
            binding: ListingDetailsBinding(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:
                  theme.brightness == Brightness.dark ? 0.25 : 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, //  IMPORTANT
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= IMAGE =================
              Stack(
                children: [
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      itemCount: widget.listingModel.images.length,
                      onPageChanged: (i) {
                        setState(() => currentImage = i);
                      },
                      itemBuilder: (_, i) {
                        return Hero(
                          tag: widget.listingModel.id,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: AppCachedImageNetwork(
                              imageUrl: widget.listingModel.images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// 🌫️ GRADIENT OVERLAY
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha:0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  ///  BOOSTED
                  if (widget.listingModel.isBoosted ?? false)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "BOOSTED",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  ///  FAVORITE
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        wishlistController.toggleWishlist(widget.listingModel);
                      },
                      child: Obx(() {
                        final isFav = wishlistController.isFavorite(
                          widget.listingModel.id,
                        );

                        return AnimatedScale(
                          scale: isFav ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha:0.4),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  /// 👁 PREMIUM VIEWS BADGE
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            formatViews(widget.listingModel.views),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /// ================= DETAILS =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 💰 PRICE
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          '₹ ${widget.listingModel.price}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          TimeAgoUtil.timeAgo(widget.listingModel.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    ///  TITLE
                    Text(
                      widget.listingModel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 👤 SELLER
                    Row(
                      children: [
                        const Icon(Icons.person, size: 13, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.listingModel.seller["name"] ??
                                "Unknown Seller",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 📍 LOCATION + DISTANCE
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            getDisplayLocation(widget.listingModel.location),
                            style: const TextStyle(
                              fontSize: 11,

                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.near_me, size: 13, color: Colors.grey),
                        SizedBox(width: 5),

                        Text(
                          homeCtrl.calculateDistance(
                                    sellerLat: widget.listingModel.lat,
                                    sellerLong: widget.listingModel.long,
                                  ) <
                                  1
                              ? "${(homeCtrl.calculateDistance(sellerLat: widget.listingModel.lat, sellerLong: widget.listingModel.long) * 1000).toStringAsFixed(0)} m away"
                              : "${homeCtrl.calculateDistance(sellerLat: widget.listingModel.lat, sellerLong: widget.listingModel.long).toStringAsFixed(1)} km away",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

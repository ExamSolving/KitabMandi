import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/utils/time_ago_utils.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/listing_details/binding/listing_details_binding.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/features/wishlist/controller/wishlist_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class ListingGridCard extends StatelessWidget {
  final ListingModel listingModel;
  const ListingGridCard({super.key, required this.listingModel});

  static final _wishCtrl = Get.find<WishlistController>();
  static final _homeCtrl = Get.find<HomeController>();

  String _fmtViews(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  String _location(Map<String, dynamic> loc) {
    final sub = loc['subLocality'] as String? ?? '';
    final l = loc['locality'] as String? ?? '';
    final city = loc['city'] as String? ?? '';
    if (sub.isNotEmpty && l.isNotEmpty) return '$sub, $l';
    if (l.isNotEmpty) return l;
    return city;
  }

  String _dist() {
    final d = _homeCtrl.calculateDistance(
      sellerLat: listingModel.lat,
      sellerLong: listingModel.long,
    );
    return d < 1
        ? '${(d * 1000).toStringAsFixed(0)} m away'
        : '${d.toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => Get.to(
        () => ListingDetailsView(listing: listingModel, docId: listingModel.id),
        binding: ListingDetailsBinding(),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: listingModel.images.isNotEmpty
                      ? AppCachedImageNetwork(
                          imageUrl: listingModel.images[0],
                          height: 156,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 156,
                          color: primary.withValues(alpha: 0.08),
                          child: Icon(Icons.menu_book_rounded,
                              size: 44,
                              color: primary.withValues(alpha: 0.3)),
                        ),
                ),

                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 70,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // FEATURED badge
                if (listingModel.isBoosted ?? false)
                  Positioned(
                    top: 9,
                    left: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFE53935)]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                // Heart button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final fav = _wishCtrl.isFavorite(listingModel.id);
                    return GestureDetector(
                      onTap: () =>
                          _wishCtrl.toggleWishlist(listingModel),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fav
                              ? Colors.red.withValues(alpha: 0.18)
                              : Colors.black.withValues(alpha: 0.38),
                        ),
                        child: Icon(
                          fav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: fav ? Colors.red : Colors.white,
                          size: 17,
                        ),
                      ),
                    );
                  }),
                ),

                // Views pill — bottom left
                Positioned(
                  bottom: 9,
                  left: 9,
                  child: _ImagePill(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_rounded,
                            size: 10, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          _fmtViews(listingModel.views),
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                // Time — bottom right
                Positioned(
                  bottom: 9,
                  right: 9,
                  child: _ImagePill(
                    child: Text(
                      TimeAgoUtil.timeAgo(listingModel.createdAt),
                      style: const TextStyle(
                          fontSize: 9.5,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),

            // ── Details ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    '₹${listingModel.price}',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: -0.4,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Title (2 lines)
                  Text(
                    listingModel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // Location row
                  _MetaRow(
                    icon: Icons.location_on_rounded,
                    iconColor: theme.hintColor,
                    child: Text(
                      _location(listingModel.location),
                      style: TextStyle(
                          fontSize: 11, color: theme.hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Distance row
                  _MetaRow(
                    icon: Icons.near_me_rounded,
                    iconColor: primary.withValues(alpha: 0.65),
                    child: Text(
                      _dist(),
                      style: TextStyle(
                        fontSize: 11,
                        color: primary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

// ── Tiny glass pill on image ──────────────────────────────────────────────────
class _ImagePill extends StatelessWidget {
  final Widget child;
  const _ImagePill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

// ── Icon + text meta row ──────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _MetaRow(
      {required this.icon, required this.iconColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 4),
        Expanded(child: child),
      ],
    );
  }
}

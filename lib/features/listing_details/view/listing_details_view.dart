import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing_details/controller/listing_details_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';
import 'package:kitab_mandi/widgets/app_image_view.dart';

class ListingDetailsView extends StatefulWidget {
  final ListingModel listing;
  final String docId;

  const ListingDetailsView({
    super.key,
    required this.listing,
    required this.docId,
  });

  @override
  State<ListingDetailsView> createState() => _ListingDetailsViewState();
}

class _ListingDetailsViewState extends State<ListingDetailsView> {
  final controller = Get.find<ListingDetailsController>();
  final chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    controller.incrementViews(widget.docId);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _subTitle(ListingModel l) {
    switch (l.mainCategory) {
      case 'School Books':
        return 'board'.tr;
      case 'Academic Books':
        return 'stream'.tr;
      case 'Competitive Exams':
        return 'exam_type'.tr;
      default:
        return 'sub_category'.tr;
    }
  }

  String _childTitle(ListingModel l) {
    switch (l.mainCategory) {
      case 'School Books':
        return 'class_label'.tr;
      case 'Academic Books':
        return 'branch'.tr;
      case 'Competitive Exams':
        return 'exam'.tr;
      default:
        return 'type'.tr;
    }
  }

  bool _canEdit(DateTime? createdAt) {
    if (createdAt == null) return true;
    return DateTime.now().difference(createdAt).inHours < 3;
  }

  String _fmtViews(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M views';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K views';
    return '$v views';
  }

  Color _conditionColor(String c) {
    switch (c.toLowerCase()) {
      case 'new':
        return const Color(0xFF10B981);
      case 'like new':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    final images = List<String>.from(widget.listing.images);
    // Responsive image height: 75% of screen width, minimum 260
    final imageHeight = (size.width * 0.78).clamp(260.0, 340.0) + topPad;

    final bg = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F6FA);
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final subText = isDark ? Colors.white60 : Colors.black54;
    final onSurface = isDark ? Colors.white : const Color(0xFF1A1D23);

    final sellerName =
        widget.listing.seller['name']?.toString().trim() ?? '';
    final initial =
        sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        extendBodyBehindAppBar: true,
        // Transparent floating app bar — back button overlays the hero image.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: Get.back,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),

        body: Column(
          children: [
            // ── Hero image ─────────────────────────────────────────────────
            GestureDetector(
              // Single tap handler on the whole image area — uses the reactive
              // current index so it always opens the page the user is on.
              onTap: () {
                if (images.isNotEmpty) {
                  Get.to(() => FullScreenImageView(
                        images: images,
                        initialIndex: controller.currentIndex.value,
                      ));
                }
              },
              child: SizedBox(
              height: imageHeight,
              child: Stack(
                children: [
                  // Carousel — items are plain images, no nested GestureDetector
                  CarouselSlider(
                    options: CarouselOptions(
                      height: imageHeight,
                      viewportFraction: 1,
                      onPageChanged: (i, _) => controller.changeIndex(i),
                    ),
                    items: images.isNotEmpty
                        ? images.map((img) => AppCachedImageNetwork(
                              width: size.width,
                              fit: BoxFit.cover,
                              imageUrl: img,
                            )).toList()
                        : [
                            Container(
                              color: isDark
                                  ? const Color(0xFF1A1D23)
                                  : const Color(0xFFF0F0F0),
                              child: Icon(Icons.menu_book_rounded,
                                  size: 64,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.3)),
                            ),
                          ],
                  ),

                  // Bottom gradient — taller so it covers the full info bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight * 0.60,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xDD000000)],
                        ),
                      ),
                    ),
                  ),

                  // Single bottom info bar: views → price + condition → dots
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Views pill
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility_rounded,
                                    size: 13, color: Colors.white70),
                                const SizedBox(width: 5),
                                Text(
                                  _fmtViews(widget.listing.views),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Price (left) + Condition badge (right)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₹${widget.listing.price}',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 12,
                                        color: Colors.black45),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _conditionColor(
                                      widget.listing.condition),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _conditionColor(
                                              widget.listing.condition)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.listing.condition,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dots — only when multiple images
                        if (images.length > 1) ...[
                          const SizedBox(height: 8),
                          Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(images.length,
                                    (i) {
                                  final active =
                                      controller.currentIndex.value == i;
                                  return AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 280),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    height: 5,
                                    width: active ? 20 : 5,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      color: active
                                          ? Colors.white
                                          : Colors.white
                                              .withValues(alpha: 0.45),
                                    ),
                                  );
                                }),
                              )),
                        ],

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ), // GestureDetector

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.listing.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 15, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.listing.location['fullAddress'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13, color: subText, height: 1.4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Book details card
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'category'.tr,
                            value: widget.listing.mainCategory,
                            icon: Icons.category_rounded,
                            isDark: isDark,
                            isLast: false,
                          ),
                          _DetailRow(
                            label: _subTitle(widget.listing),
                            value: widget.listing.subCategory,
                            icon: Icons.bookmark_rounded,
                            isDark: isDark,
                            isLast:
                                widget.listing.childCategory.isEmpty,
                          ),
                          if (widget.listing.childCategory.isNotEmpty)
                            _DetailRow(
                              label: _childTitle(widget.listing),
                              value: widget.listing.childCategory,
                              icon: Icons.menu_book_rounded,
                              isDark: isDark,
                              isLast: true,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'description'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.listing.description,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.65,
                        color: subText,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Seller card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sellerName.isNotEmpty
                                      ? sellerName
                                      : 'unknown_seller'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'listed_by_seller'.tr,
                                  style: TextStyle(
                                      fontSize: 12, color: subText),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.verified_rounded,
                              size: 20, color: AppColors.primary),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Bottom action bar ──────────────────────────────────────────────
        bottomNavigationBar: Builder(
          builder: (ctx) {
            final currentUid = controller.currentUser?.uid;
            final isOwner = currentUid == widget.listing.seller['uid'];
            final isSold = widget.listing.isSold == true;
            final bottomPad = MediaQuery.of(ctx).padding.bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
              decoration: BoxDecoration(
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDark ? 0.3 : 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: isOwner
                  ? Row(
                      children: [
                        Expanded(
                          child: Builder(builder: (context) {
                            final editAllowed = !isSold &&
                                _canEdit(widget.listing.createdAt);
                            return Tooltip(
                              message: isSold
                                  ? 'listing_is_sold_tooltip'.tr
                                  : !_canEdit(widget.listing.createdAt)
                                      ? 'editing_locked_tooltip'.tr
                                      : '',
                              child: OutlinedButton.icon(
                                onPressed: editAllowed
                                    ? () => Get.toNamed(
                                          AppRoutes.addListing,
                                          arguments: {
                                            'listing': widget.listing
                                          },
                                        )
                                    : null,
                                icon: Icon(
                                  editAllowed
                                      ? Icons.edit_rounded
                                      : Icons.lock_rounded,
                                  size: 17,
                                ),
                                label: Text(
                                  editAllowed
                                      ? 'edit'.tr
                                      : 'locked'.tr,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  foregroundColor: editAllowed
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                                  side: BorderSide(
                                    color: editAllowed
                                        ? AppColors.primary
                                            .withValues(alpha: 0.5)
                                        : (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: 0.15),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isDeleting.value
                                  ? null
                                  : () => controller
                                      .confirmDelete(widget.listing),
                              icon: controller.isDeleting.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.delete_rounded,
                                      size: 17),
                              label: Text('remove'.tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Obx(() {
                      final userData =
                          Get.find<AuthController>().userData.value;
                      final sub = userData?['subscription']
                          as Map<String, dynamic>?;
                      final isActive =
                          SubscriptionService.isActive(sub);
                      final plan = SubscriptionService.getPlan(sub);
                      final canCall = isActive &&
                          plan != RazorpayConfig.planFree;
                      final sellerUid =
                          widget.listing.seller['uid']?.toString() ??
                              '';

                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async =>
                                  chatController.startChat(
                                      widget.listing),
                              icon: const Icon(
                                  Icons.chat_bubble_rounded,
                                  size: 17),
                              label: Text('chat_seller'.tr),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13),
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      controller.callSeller(sellerUid),
                                  icon: const Icon(Icons.call_rounded,
                                      size: 17),
                                  label: Text('call_seller'.tr),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canCall
                                        ? const Color(0xFF10B981)
                                        : (isDark
                                            ? const Color(0xFF2A2F38)
                                            : Colors.grey.shade200),
                                    foregroundColor: canCall
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                                if (!canCall)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.4),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                          Icons.lock_rounded,
                                          size: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
            );
          },
        ),
      ),
    );
  }
}

// ── Detail row inside the book-info card ──────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1D23),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 40,
            endIndent: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}

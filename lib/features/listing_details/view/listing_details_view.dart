import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing_details/controller/listing_details_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';
import 'package:kitab_mandi/widgets/app_image_view.dart';
import 'package:kitab_mandi/widgets/app_text.dart';

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
    controller.incrementViews(widget.docId);
    super.initState();
  }

  Color _appBarbackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF0F1115)
      : Colors.white;

  Color _card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1A1D23)
      : Colors.white;

  Color _textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white60
      : Colors.black54;

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(widget.listing.images);

    return Scaffold(
      backgroundColor: _bg(context),
      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: _appBarbackground(context),
        elevation: 0,
        title: Text('ad_details'.tr),
      ),

      body: Column(
        children: [
          // ================= IMAGE SLIDER =================
          Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 260,
                  viewportFraction: 1,
                  onPageChanged: (index, _) => controller.changeIndex(index),
                ),
                items: images.map((img) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => FullScreenImageView(
                          images: images,
                          initialIndex: images.indexOf(img),
                        ),
                      );
                    },
                    child: AppCachedImageNetwork(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: img,
                    ),
                  );
                }).toList(),
              ),

              //  DOTS
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: controller.currentIndex.value == index ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: controller.currentIndex.value == index
                              ? AppColors.primaryDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          // ================= DETAILS =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  PRICE

                  ///  VIEWS
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      AppText(
                        "₹ ${widget.listing.price}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),

                            /// 👁 VIEWS COUNT
                            Text(
                              formatViews(widget.listing.views),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  //  TITLE
                  AppText(
                    widget.listing.title,
                    maxLines: 20,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  //  LOCATION (FIXED OVERFLOW )
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AppText(
                          widget.listing.location['fullAddress'] ?? "",
                          maxLines: 2,

                          style: TextStyle(color: _textSecondary(context)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  //  DETAILS CARD
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _row(context, 'category'.tr, widget.listing.mainCategory),
                        _row(
                          context,
                          _getSubTitle(widget.listing),
                          widget.listing.subCategory,
                        ),

                        if (widget.listing.childCategory.isNotEmpty)
                          _row(
                            context,
                            _getChildTitle(widget.listing),
                            widget.listing.childCategory,
                          ),

                        _row(context, 'condition'.tr, widget.listing.condition),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  //  DESCRIPTION
                  AppText(
                    'description'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    widget.listing.description,
                    maxLines: 100,
                    style: TextStyle(
                      height: 1.5,
                      color: _textSecondary(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= BOTTOM BUTTONS =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: _card(context),
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: Builder(
          builder: (context) {
            final currentUid = controller.currentUser?.uid;
            final sellerUid = widget.listing.seller['uid'];

            ///  CHECK OWNER
            final isOwner = currentUid == sellerUid;

            if (isOwner) {
              // ================= OWNER UI =================
              return Row(
                children: [
                  // ✏️ EDIT
                  Expanded(
                    child: AppButton(
                      text: 'edit'.tr,
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.addListing,
                          arguments: {"listing": widget.listing},
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🗑 DELETE
                  Expanded(
                    child: Obx(
                      () => AppButton(
                        text: 'remove'.tr,
                        isLoading: controller.isDeleting.value,
                        backgroundColor: AppColors.secondaryDark,
                        onPressed: () {
                          controller.confirmDelete(widget.listing);
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // ================= OTHER USER UI =================
              return Row(
                children: [
                  // 💬 CHAT
                  Expanded(
                    child: AppButton(
                      backgroundColor: AppColors.secondaryDark,
                      text: 'chat_seller'.tr,
                      onPressed: () async {
                        await chatController.startChat(widget.listing);
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 📞 CALL
                  Expanded(
                    child: AppButton(
                      text: 'call_seller'.tr,
                      backgroundColor: Colors.green,
                      onPressed: () {
                        controller.makePhoneCall(
                          widget.listing.seller['phone'],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  String _getSubTitle(ListingModel listing) {
    switch (listing.mainCategory) {
      case "School Books":
        return 'board'.tr;
      case "Academic Books":
        return 'stream'.tr;
      case "Competitive Exams":
        return 'exam_type'.tr;
      default:
        return 'sub_category'.tr;
    }
  }

  String _getChildTitle(ListingModel listing) {
    switch (listing.mainCategory) {
      case "School Books":
        return 'class_label'.tr;
      case "Academic Books":
        return 'branch'.tr;
      case "Competitive Exams":
        return 'exam'.tr;
      default:
        return 'type'.tr;
    }
  }

  //  ROW FIXED RESPONSIVE
  Widget _row(BuildContext context, String title, dynamic value) {
    return Visibility(
      visible: value.toString().isNotEmpty ? true : false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: AppText(
                title,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            Expanded(
              flex: 6,
              child: AppText(
                value?.toString() ?? "",
                align: TextAlign.end,

                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
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
}

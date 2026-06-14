import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailsController extends GetxController {
  final IListingRepository _listingRepo;
  final IAuthRepository _authRepo;

  ListingDetailsController(this._listingRepo, this._authRepo);

  final RxInt currentIndex = 0.obs;
  final RxBool isDeleting = false.obs;

  // Expose current user for the view (ownership check)
  User? get currentUser => _authRepo.currentUser;

  void changeIndex(int index) => currentIndex.value = index;

  // ── View tracking ─────────────────────────────────────────────────────────
  Future<void> incrementViews(String docId) async {
    final uid = _authRepo.currentUser?.uid;
    if (uid == null) return;
    await _listingRepo.incrementViews(docId, uid);
  }

  // ── Delete listing ────────────────────────────────────────────────────────
  Future<void> deleteListing(String docId, List<String> images) async {
    try {
      isDeleting.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Delete images + wishlist entries + Firestore doc via repository
      await _listingRepo.deleteWishlistEntries(docId);
      await _listingRepo.deleteListing(docId, images);

      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Deleted',
        'Listing removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (Get.isOverlaysOpen) Get.back();
      Get.back(result: true);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchTopViewedListings();
      }
      if (Get.isRegistered<MyAdsController>()) {
        Get.find<MyAdsController>().fetchMyAds();
      }
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to delete listing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void confirmDelete(ListingModel ad) {
    final theme = Get.theme;
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'delete_listing'.tr,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'delete_listing_confirm'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('cancel'.tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        deleteListing(ad.id, ad.images);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: isDark ? 0 : 2,
                      ),
                      child: Text(
                        'remove'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Phone call ────────────────────────────────────────────────────────────
  Future<void> makePhoneCall(String phoneNumber) async {
    final url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar('Error', 'Could not open dialer');
    }
  }
}

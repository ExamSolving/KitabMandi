import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
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

      // Refresh home and my-ads feeds before navigating away.
      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        hc.fetchAllListings();
        hc.fetchTopViewedListings();
      }
      if (Get.isRegistered<MyAdsController>()) {
        Get.find<MyAdsController>().fetchMyAds();
      }

      // Navigate to dashboard, clearing the detail screen from the stack.
      Get.offAllNamed(AppRoutes.dashboard);

      Get.snackbar(
        'Deleted',
        'Listing removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
      );
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

  // ── Call seller (subscription-gated) ─────────────────────────────────────
  /// Checks that the current user has an active Plus or Pro plan, then fetches
  /// the seller's phone number from Firestore and opens the native dialer.
  Future<void> callSeller(String sellerUid) async {
    // 1. Subscription gate
    try {
      final userData = Get.find<AuthController>().userData.value;
      final sub = userData?['subscription'] as Map<String, dynamic>?;
      final isActive = SubscriptionService.isActive(sub);
      final plan = SubscriptionService.getPlan(sub);
      final isFree = !isActive || plan == RazorpayConfig.planFree;

      if (isFree) {
        _showCallUpgradeDialog();
        return;
      }
    } catch (_) {
      _showCallUpgradeDialog();
      return;
    }

    // 2. Fetch phone number from users collection
    if (sellerUid.isEmpty) {
      Get.snackbar('Error', 'Seller information unavailable.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerUid)
          .get();
      final phone = (doc.data()?['phone'] as String?)?.trim() ?? '';

      if (phone.isEmpty) {
        Get.snackbar('Not Available',
            'Seller has not provided a phone number.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      await makePhoneCall(phone);
    } catch (_) {
      Get.snackbar('Error', 'Could not reach seller. Try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showCallUpgradeDialog() {
    final theme = Get.theme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1F28) : Colors.white;

    Get.dialog(
      Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.call_rounded,
                    color: Color(0xFF10B981), size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Call Seller',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Calling sellers directly is available on Plus and Pro plans. Upgrade to contact sellers by phone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: theme.hintColor.withValues(alpha: 0.3)),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(color: theme.hintColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.subscription);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Upgrade',
                          style: TextStyle(fontWeight: FontWeight.w700)),
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

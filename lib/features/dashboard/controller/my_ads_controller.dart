import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';

class MyAdsController extends GetxController {
  final IListingRepository _listingRepo;
  final IAuthRepository _authRepo;

  MyAdsController(this._listingRepo, this._authRepo);

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxList<ListingModel> myAdsList = <ListingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyAds();
  }

  Future<void> fetchMyAds() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final uid = _authRepo.currentUser?.uid;
      // No uid means the auth state isn't ready yet — return silently.
      // The auth wrapper will re-trigger navigation once auth resolves.
      if (uid == null) return;
      final ads = await _listingRepo.getMyListings(uid);
      myAdsList.assignAll(ads);
    } catch (_) {
      // Don't show a snackbar here — the UI renders an inline error state
      // with a retry button so the user can recover without intrusive toasts.
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAd(ListingModel ad) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      await _listingRepo.deleteListing(ad.id, ad.images);
      if (Get.isDialogOpen ?? false) Get.back();
      myAdsList.removeWhere((e) => e.id == ad.id);
      AppSnackbar.success('ad_deleted'.tr);
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackbar.error('ad_delete_failed'.tr);
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
                'confirm_delete_title'.tr,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'confirm_delete_msg'.tr,
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
                        deleteAd(ad);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: isDark ? 0 : 2,
                      ),
                      child: Text(
                        'delete'.tr,
                        style: const TextStyle(color: AppColors.white),
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
}

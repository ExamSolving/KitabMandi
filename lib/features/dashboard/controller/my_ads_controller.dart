import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class MyAdsController extends GetxController {
  var isLoading = false.obs;
  var myAdsList = [].obs;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchMyAds();
    super.onInit();
  }

  Future<void> fetchMyAds() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final snapshot = await _firestore
          .collection("listings")
          .where("seller.uid", isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        myAdsList.clear();
        return;
      }

      final ads = snapshot.docs.map((doc) {
        final data = doc.data();
        return ListingModel.fromMap(data);
      }).toList();

      myAdsList.assignAll(ads);
    } on FirebaseException catch (e) {
      AppSnackbar.error(_handleFirestoreError(e));
    } catch (e) {
      AppSnackbar.error("Failed to load your ads");
    } finally {
      isLoading.value = false;
    }
  }

  void editAd(ad) {
    // Get.snackbar("Edit", "Edit ${ad['title']}");
  }

  Future<void> deleteAd(ListingModel ad) async {
    try {
      // 🔄 Loader
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // ================= DELETE IMAGES =================
      if (ad.images.isNotEmpty) {
        for (String imageUrl in ad.images) {
          try {
            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
          } catch (e) {
            print("Image delete failed: $e");
            // ⚠️ continue even if one image fails
          }
        }
      }

      // ================= DELETE FIRESTORE DOC =================
      await FirebaseFirestore.instance
          .collection('listings') // 🔁 your collection
          .doc(ad.id)
          .delete();

      // ================= CLOSE LOADER =================
      Get.back();

      // ================= UPDATE UI =================
      myAdsList.removeWhere((e) => e.id == ad.id);

      Get.snackbar("Deleted", "Ad removed successfully");
    } catch (e) {
      Get.back();

      Get.snackbar(
        "Error",
        "Failed to delete ad",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
              //  Icon Circle
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              // 📝 Title
              Text(
                "Delete Ad?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              //  Description
              Text(
                "This action will permanently remove your ad. This cannot be undone.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 20),

              //  Buttons
              Row(
                children: [
                  // Cancel Button
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
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Delete Button
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
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: AppColors.white),
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

  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return "Permission denied";
      case 'unavailable':
        return "No internet connection";
      case 'not-found':
        return "Data not found";
      default:
        return e.message ?? "Something went wrong";
    }
  }
}

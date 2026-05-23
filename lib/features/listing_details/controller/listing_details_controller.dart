import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailsController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isDeleting = false.obs;
  final currentUser = FirebaseAuth.instance.currentUser;
  final myAdsCtrl = Get.find<MyAdsController>();

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  //=================INCREAMENT PER USER ONCE=============
  Future<void> incrementViews(String docId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('listings').doc(docId);

    final doc = await docRef.get();

    if (!doc.exists) return;

    List viewedBy = (doc.data() as Map<String, dynamic>).containsKey('viewedBy')
        ? doc['viewedBy']
        : [];

    // ✅ If already viewed → DO NOTHING
    if (viewedBy.contains(user.uid)) {
      return;
    }

    // ✅ Else → increment + add user
    await docRef.update({
      'views': FieldValue.increment(1),
      'viewedBy': FieldValue.arrayUnion([user.uid]),
    });
  }

  // ================= DELETE LISTING =================
  Future<void> deleteListing(String docId, List<String> images) async {
    try {
      isDeleting.value = true;

      /// ================= SHOW LOADER =================
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      /// ================= DELETE IMAGES =================
      for (String url in images) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (e) {
          debugPrint("Image delete failed: $e");
        }
      }

      /// ================= DELETE FROM WISHLIST =================
      /// (Assuming flat collection: wishlist/{id})
      try {
        final wishlistSnap = await FirebaseFirestore.instance
            .collection('wishlist')
            .where('listingId', isEqualTo: docId)
            .get();

        for (var doc in wishlistSnap.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Wishlist cleanup failed: $e");
      }

      /// ================= DELETE LISTING =================
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(docId)
          .delete();

      /// ================= CLOSE LOADER =================
      if (Get.isDialogOpen ?? false) Get.back();

      /// ================= SHOW SUCCESS =================
      Get.snackbar(
        "Deleted",
        "Listing removed successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      /// small delay so user sees snackbar
      await Future.delayed(const Duration(milliseconds: 600));

      /// ================= NAVIGATION =================
      if (Get.isOverlaysOpen) Get.back(); // close snackbar if needed
      Get.back(result: true); // go back to previous screen

      /// ================= REFRESH DATA =================
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchListings();
      }

      if (Get.isRegistered<MyAdsController>()) {
        Get.find<MyAdsController>().fetchMyAds();
      }
    } catch (e) {
      debugPrint("DELETE ERROR: $e");

      /// close loader safely
      if (Get.isDialogOpen ?? false) Get.back();

      /// error snackbar
      Get.snackbar(
        "Error",
        "Failed to delete listing",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  // ================= CONFIRM DELETE DIALOG =================
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
              // 🔥 ICON
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

              // 🔥 TITLE
              Text(
                "Delete Listing?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 🔥 DESCRIPTION
              Text(
                "This action will permanently remove your listing. This cannot be undone.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 BUTTONS
              Row(
                children: [
                  // Cancel
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

                  // Delete
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // close dialog
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
                      child: const Text(
                        "Remove",
                        style: TextStyle(color: Colors.white),
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

  //==================CALL TO SELLER===========
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar("Error", "Could not open dialer");
    }
  }
}

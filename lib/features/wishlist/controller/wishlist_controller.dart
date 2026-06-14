import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/wishlist/domain/repositories/i_wishlist_repository.dart';

class WishlistController extends GetxController {
  final IWishlistRepository _wishlistRepo;
  final IAuthRepository _authRepo;

  WishlistController(this._wishlistRepo, this._authRepo);

  final RxList<ListingModel> wishlist = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;

  String? get _userId => _authRepo.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  void fetchWishlist() {
    final uid = _userId;
    if (uid == null) return;
    isLoading.value = true;
    _wishlistRepo.getWishlist(uid).listen(
      (items) {
        wishlist.value = items;
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('Wishlist stream error: $e');
        isLoading.value = false;
      },
    );
  }

  Future<void> addToWishlist(ListingModel item) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _wishlistRepo.addToWishlist(uid, item);
    } catch (e) {
      debugPrint('Add wishlist error: $e');
    }
  }

  Future<void> removeFromWishlist(String listingId) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _wishlistRepo.removeFromWishlist(uid, listingId);
    } catch (e) {
      debugPrint('Remove wishlist error: $e');
    }
  }

  Future<void> toggleWishlist(ListingModel item) async {
    if (isFavorite(item.id)) {
      await removeFromWishlist(item.id);
    } else {
      await addToWishlist(item);
    }
  }

  bool isFavorite(String listingId) =>
      wishlist.any((item) => item.id == listingId);
}

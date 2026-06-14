import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

abstract class IWishlistRepository {
  /// Real-time stream of the user's saved listings.
  Stream<List<ListingModel>> getWishlist(String userId);

  Future<void> addToWishlist(String userId, ListingModel item);
  Future<void> removeFromWishlist(String userId, String listingId);
}

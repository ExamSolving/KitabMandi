import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

/// Contract for all listing-related data operations.
/// Used by: HomeController, MyAdsController, SellerController,
///           ListingDetailsController.
abstract class IListingRepository {
  // ── Queries ───────────────────────────────────────────────────────────────
  Future<List<ListingModel>> getListings({int limit = 100});
  Future<List<ListingModel>> getMyListings(String uid);

  // ── Mutations ─────────────────────────────────────────────────────────────
  /// Returns the Firestore document ID of the created listing.
  Future<String> createListing(Map<String, dynamic> data);
  Future<void> updateListing(String id, Map<String, dynamic> data);

  /// Deletes images from Storage then removes the Firestore document.
  Future<void> deleteListing(String id, List<String> imageUrls);

  // ── Engagement ────────────────────────────────────────────────────────────
  Future<void> incrementViews(String id, String userId);

  // ── Storage helpers ───────────────────────────────────────────────────────
  /// Uploads a local file and returns its download URL.
  Future<String> uploadImage(String localPath);

  /// Removes a file from Storage by its download URL.
  Future<void> deleteImage(String url);

  // ── Cross-feature cleanup ────────────────────────────────────────────────
  /// Removes all wishlist documents referencing [listingId].
  Future<void> deleteWishlistEntries(String listingId);
}

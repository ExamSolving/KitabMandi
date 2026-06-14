import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class WishlistRemoteDataSource {
  final FirebaseFirestore _firestore;

  WishlistRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stores only a lightweight pointer in the wishlist subcollection, then
  // live-fetches the actual listing data from the listings collection.
  // This means wishlist items always reflect the seller's latest price/title/images
  // and are automatically removed if the listing is hard-deleted.
  Stream<List<ListingModel>> getWishlist(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          if (snap.docs.isEmpty) return <ListingModel>[];

          final ids = snap.docs.map((d) => d.id).toList();
          final results = <ListingModel>[];

          // Firestore whereIn supports max 30 items per query
          for (var i = 0; i < ids.length; i += 30) {
            final chunk = ids.sublist(
              i,
              (i + 30) < ids.length ? (i + 30) : ids.length,
            );
            final listingSnap = await _firestore
                .collection('listings')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
            results.addAll(
              listingSnap.docs
                  .map((d) => ListingModel.fromMap(d.data(), d.id)),
            );
          }
          return results;
        });
  }

  // Store only a pointer — never snapshot full listing data into wishlist
  Future<void> addToWishlist(String userId, ListingModel item) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(item.id)
          .set({
            'listingId': item.id,
            'createdAt': FieldValue.serverTimestamp(),
          });

  Future<void> removeFromWishlist(String userId, String listingId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(listingId)
          .delete();
}

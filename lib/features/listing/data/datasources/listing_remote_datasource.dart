import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class ListingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ListingRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Public feed — newest first. Status filter is applied in Dart so no composite
  // index is required and old listings without a status field still appear.
  Future<List<ListingModel>> getListings({int limit = 100}) async {
    final snap = await _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .where((d) {
          final status = d.data()['status'] as String?;
          // null means a pre-migration listing — treat as active
          return status == null || status == 'active';
        })
        .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Seller's own listings — all statuses except deleted, newest first.
  // No orderBy compound query used here to avoid requiring a composite index.
  // Sorting is done in Dart after the fetch.
  Future<List<ListingModel>> getMyListings(String uid) async {
    final snap = await _firestore
        .collection('listings')
        .where('seller.uid', isEqualTo: uid)
        .get();
    final listings = snap.docs
        .where((d) => d.data()['status'] != 'deleted')
        .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
        .toList();
    listings.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return listings;
  }

  Future<String> createListing(Map<String, dynamic> data) async {
    final doc = _firestore.collection('listings').doc();
    await doc.set({...data, 'id': doc.id});
    return doc.id;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) =>
      _firestore.collection('listings').doc(id).update(data);

  // Soft delete — sets status to 'deleted' so the listing is excluded from
  // the public feed query without destroying the data.
  Future<void> deleteListing(String id) =>
      _firestore.collection('listings').doc(id).update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });

  // Uses a Firestore transaction so views and viewedBy stay consistent.
  Future<void> incrementViews(String id, String userId) async {
    final docRef = _firestore.collection('listings').doc(id);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final viewedBy =
          List<String>.from(snap.data()?['viewedBy'] ?? []);
      if (viewedBy.contains(userId)) return;
      tx.update(docRef, {
        'views': FieldValue.increment(1),
        'viewedBy': FieldValue.arrayUnion([userId]),
      });
    });
  }

  Future<String> uploadImage(String localPath) async {
    final ref = _storage
        .ref()
        .child('listings/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(localPath));
    return ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) =>
      _storage.refFromURL(url).delete();

  Future<void> deleteWishlistEntries(String listingId) async {
    final snap = await _firestore
        .collection('wishlist')
        .where('listingId', isEqualTo: listingId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }
}

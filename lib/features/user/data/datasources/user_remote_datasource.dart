import 'package:cloud_firestore/cloud_firestore.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Uses Firestore count() aggregation — one read regardless of document count.
  // Requires cloud_firestore >= 4.0.0 (AggregateQuery support).
  Future<int> countListings(String uid) async {
    final agg = await _firestore
        .collection('listings')
        .where('seller.uid', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .count()
        .get();
    return agg.count ?? 0;
  }

  Future<int> countSoldListings(String uid) async {
    final agg = await _firestore
        .collection('listings')
        .where('seller.uid', isEqualTo: uid)
        .where('isSold', isEqualTo: true)
        .count()
        .get();
    return agg.count ?? 0;
  }
}

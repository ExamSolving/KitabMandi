import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Runs once per dashboard open (in the background).
/// Hard-deletes any listing that was marked sold more than 7 days ago,
/// together with its Storage images, all related chats (messages +
/// chat images), and wishlist entries.
class SoldCleanupService {
  static Future<void> run(String uid) async {
    try {
      await _cleanup(uid);
    } catch (e) {
      debugPrint('SoldCleanupService: $e');
    }
  }

  static Future<void> _cleanup(String uid) async {
    final fs = FirebaseFirestore.instance;
    final st = FirebaseStorage.instance;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));

    // Fetch sold listings for this seller.
    // Filter soldAt in Dart — avoids needing a composite Firestore index.
    final snap = await fs
        .collection('listings')
        .where('seller.uid', isEqualTo: uid)
        .where('status', isEqualTo: 'sold')
        .get();

    final expired = snap.docs.where((doc) {
      final raw = doc.data()['soldAt'];
      if (raw == null) return false;
      return (raw as Timestamp).toDate().isBefore(cutoff);
    }).toList();

    for (final listingDoc in expired) {
      final listingId = listingDoc.id;
      final data = listingDoc.data();

      // 1. Delete listing images from Storage
      for (final url in List<String>.from(data['images'] ?? [])) {
        try {
          await st.refFromURL(url).delete();
        } catch (_) {}
      }

      // 2. Delete all chat rooms for this listing
      final chatSnap = await fs
          .collection('chats')
          .where('listingId', isEqualTo: listingId)
          .get();

      for (final chatDoc in chatSnap.docs) {
        final chatId = chatDoc.id;

        final msgsSnap = await fs
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .get();

        // Delete chat images from Storage
        for (final msg in msgsSnap.docs) {
          final d = msg.data();
          if (d['type'] == 'image') {
            final imgUrl = d['imageUrl'] as String? ?? '';
            if (imgUrl.isNotEmpty) {
              try {
                await st.refFromURL(imgUrl).delete();
              } catch (_) {}
            }
          }
        }

        // Delete message documents in batches (Firestore limit: 500 per batch)
        final refs = msgsSnap.docs.map((d) => d.reference).toList();
        for (var i = 0; i < refs.length; i += 400) {
          final batch = fs.batch();
          for (final ref in refs.skip(i).take(400)) {
            batch.delete(ref);
          }
          await batch.commit();
        }

        // Delete the chat document
        await chatDoc.reference.delete();
      }

      // 3. Delete wishlist entries
      final wishlistSnap = await fs
          .collection('wishlist')
          .where('listingId', isEqualTo: listingId)
          .get();
      if (wishlistSnap.docs.isNotEmpty) {
        final batch = fs.batch();
        for (final d in wishlistSnap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }

      // 4. Hard-delete the listing document
      await listingDoc.reference.delete();
    }
  }
}

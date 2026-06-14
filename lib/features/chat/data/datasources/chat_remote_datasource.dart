import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> startChat({
    required String chatId,
    required String buyerId,
    required String sellerId,
    required ListingModel listing,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      final batch = _firestore.batch();

      batch.set(chatRef, {
        'chatId': chatId,
        'listingId': listing.id,
        'listingTitle': listing.title,
        'price': listing.price,
        'listingImage': listing.images.isNotEmpty ? listing.images.first : '',
        'buyerId': buyerId,
        'sellerId': sellerId,
        'participants': [buyerId, sellerId],
        'lastMessage': 'Hello, is this available ??',
        'lastSenderId': buyerId,
        'isSeen': false,
        'unreadCount': 1,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      final msgRef = chatRef.collection('messages').doc();
      batch.set(msgRef, {
        'senderId': buyerId,
        'receiverId': sellerId,
        'isSeen': false,
        'message': 'Hello, is this available ??',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    }
  }

  Stream<QuerySnapshot> getBuyingChats(String userId) => _firestore
      .collection('chats')
      .where('buyerId', isEqualTo: userId)
      .snapshots();

  Stream<QuerySnapshot> getSellingChats(String userId) => _firestore
      .collection('chats')
      .where('sellerId', isEqualTo: userId)
      .snapshots();

  Stream<QuerySnapshot> getChatsForListing(
    String sellerId,
    String listingId,
  ) =>
      _firestore
          .collection('chats')
          .where('sellerId', isEqualTo: sellerId)
          .where('listingId', isEqualTo: listingId)
          .snapshots();

  Stream<QuerySnapshot> getMessagesForChat(String chatId) => _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots();

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
    String receiverId = '',
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    final batch = _firestore.batch();

    batch.set(msgRef, {
      'senderId': senderId,
      if (receiverId.isNotEmpty) 'receiverId': receiverId,
      'isSeen': false,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(chatRef, {
      'lastMessage': message,
      'lastSenderId': senderId,
      'isSeen': false,
      'unreadCount': FieldValue.increment(1),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Marks all messages NOT sent by userId as seen, then resets the chat's
  // unread counter. Uses a batch write — no N individual update() calls.
  Future<void> markMessagesAsSeen(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isSeen', isEqualTo: false)
          .get();

      if (messages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        // Only mark messages that were sent by the OTHER user
        if (doc.data()['senderId'] != userId) {
          batch.update(doc.reference, {'isSeen': true});
        }
      }
      batch.update(
        _firestore.collection('chats').doc(chatId),
        {'unreadCount': 0, 'isSeen': true},
      );

      await batch.commit();
    } catch (e) {
      debugPrint('markMessagesAsSeen error: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('User fetch error: $e');
      return null;
    }
  }
}

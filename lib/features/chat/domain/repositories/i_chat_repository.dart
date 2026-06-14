import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

abstract class IChatRepository {
  /// Creates a chat document + initial message if one does not already exist.
  Future<void> startChat({
    required String chatId,
    required String buyerId,
    required String sellerId,
    required ListingModel listing,
  });

  Stream<QuerySnapshot> getBuyingChats(String userId);
  Stream<QuerySnapshot> getSellingChats(String userId);
  Stream<QuerySnapshot> getChatsForListing(String sellerId, String listingId);
  Stream<QuerySnapshot> getMessagesForChat(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
    String receiverId = '',
  });

  Future<void> markMessagesAsSeen(String chatId, String userId);

  Future<Map<String, dynamic>?> getUserById(String uid);
}

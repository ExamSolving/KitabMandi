import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitab_mandi/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:kitab_mandi/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDataSource _ds;
  const ChatRepositoryImpl(this._ds);

  @override
  Future<void> startChat({
    required String chatId,
    required String buyerId,
    required String sellerId,
    required ListingModel listing,
  }) =>
      _ds.startChat(
        chatId: chatId,
        buyerId: buyerId,
        sellerId: sellerId,
        listing: listing,
      );

  @override
  Stream<QuerySnapshot> getBuyingChats(String userId) =>
      _ds.getBuyingChats(userId);

  @override
  Stream<QuerySnapshot> getSellingChats(String userId) =>
      _ds.getSellingChats(userId);

  @override
  Stream<QuerySnapshot> getChatsForListing(
    String sellerId,
    String listingId,
  ) =>
      _ds.getChatsForListing(sellerId, listingId);

  @override
  Stream<QuerySnapshot> getMessagesForChat(String chatId) =>
      _ds.getMessagesForChat(chatId);

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
    String receiverId = '',
  }) =>
      _ds.sendMessage(
        chatId: chatId,
        senderId: senderId,
        message: message,
        receiverId: receiverId,
      );

  @override
  Future<void> markMessagesAsSeen(String chatId, String userId) =>
      _ds.markMessagesAsSeen(chatId, userId);

  @override
  Future<Map<String, dynamic>?> getUserById(String uid) =>
      _ds.getUserById(uid);
}

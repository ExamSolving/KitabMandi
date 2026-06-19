import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class ChatController extends GetxController {
  final IChatRepository _chatRepo;
  final IAuthRepository _authRepo;

  ChatController(this._chatRepo, this._authRepo);

  final Map<String, Map<String, dynamic>> userCache = {};

  String? get _userId => _authRepo.currentUser?.uid;

  // Public — needed by UsersListView to determine sender vs receiver
  String? get currentUserId => _authRepo.currentUser?.uid;

  // ── Start chat ────────────────────────────────────────────────────────────
  Future<void> startChat(ListingModel listing) async {
    final buyerId = _userId!;
    final sellerId = listing.seller['uid'] as String;
    final chatId = '${listing.id}_$buyerId';

    // Navigate first for instant response
    Get.toNamed(AppRoutes.chatRoom, arguments: {
      'chatId': chatId,
      'listingTitle': listing.title,
      'listingImage':
          listing.images.isNotEmpty ? listing.images.first : '',
      'userName': listing.seller['name']?.toString() ?? '',
      'otherUserId': sellerId,
      'listingId': listing.id,
      'sellerUid': sellerId,
    });

    // Background setup
    await _chatRepo.startChat(
      chatId: chatId,
      buyerId: buyerId,
      sellerId: sellerId,
      listing: listing,
    );
  }

  // ── Streams ───────────────────────────────────────────────────────────────
  Stream<QuerySnapshot> getBuyingProducts() =>
      _chatRepo.getBuyingChats(_userId!);

  Stream<QuerySnapshot> getSellingProducts() =>
      _chatRepo.getSellingChats(_userId!);

  Stream<QuerySnapshot> getUsersForListing(String listingId) =>
      _chatRepo.getChatsForListing(_userId!, listingId);

  // ── Read / seen ───────────────────────────────────────────────────────────
  Future<void> markMessagesAsSeen(String chatId, String myId) =>
      _chatRepo.markMessagesAsSeen(chatId, myId);

  Future<Map<String, dynamic>?> getUserById(String uid) =>
      _chatRepo.getUserById(uid);

  Future<Map<String, dynamic>?> getUserCached(String uid) async {
    if (userCache.containsKey(uid)) return userCache[uid];
    final user = await getUserById(uid);
    if (user != null) userCache[uid] = user;
    return user;
  }
}

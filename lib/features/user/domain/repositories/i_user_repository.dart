abstract class IUserRepository {
  Future<Map<String, dynamic>?> getUserProfile(String uid);
  Future<int> countListings(String uid);
  Future<int> countSoldListings(String uid);
}

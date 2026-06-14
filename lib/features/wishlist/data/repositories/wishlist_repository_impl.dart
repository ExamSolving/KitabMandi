import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:kitab_mandi/features/wishlist/domain/repositories/i_wishlist_repository.dart';

class WishlistRepositoryImpl implements IWishlistRepository {
  final WishlistRemoteDataSource _ds;
  const WishlistRepositoryImpl(this._ds);

  @override
  Stream<List<ListingModel>> getWishlist(String userId) =>
      _ds.getWishlist(userId);

  @override
  Future<void> addToWishlist(String userId, ListingModel item) =>
      _ds.addToWishlist(userId, item);

  @override
  Future<void> removeFromWishlist(String userId, String listingId) =>
      _ds.removeFromWishlist(userId, listingId);
}

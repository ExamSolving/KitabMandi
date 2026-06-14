import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';

class ListingRepositoryImpl implements IListingRepository {
  final ListingRemoteDataSource _ds;
  const ListingRepositoryImpl(this._ds);

  @override
  Future<List<ListingModel>> getListings({int limit = 100}) =>
      _ds.getListings(limit: limit);

  @override
  Future<List<ListingModel>> getMyListings(String uid) =>
      _ds.getMyListings(uid);

  @override
  Future<String> createListing(Map<String, dynamic> data) =>
      _ds.createListing(data);

  @override
  Future<void> updateListing(String id, Map<String, dynamic> data) =>
      _ds.updateListing(id, data);

  @override
  Future<void> deleteListing(String id, List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await _ds.deleteImage(url);
      } catch (_) {
        // continue — a missing image must not block the delete
      }
    }
    await _ds.deleteListing(id);
  }

  @override
  Future<void> incrementViews(String id, String userId) =>
      _ds.incrementViews(id, userId);

  @override
  Future<String> uploadImage(String localPath) => _ds.uploadImage(localPath);

  @override
  Future<void> deleteImage(String url) => _ds.deleteImage(url);

  @override
  Future<void> deleteWishlistEntries(String listingId) =>
      _ds.deleteWishlistEntries(listingId);
}

import 'package:kitab_mandi/features/user/data/datasources/user_remote_datasource.dart';
import 'package:kitab_mandi/features/user/domain/repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource _ds;
  const UserRepositoryImpl(this._ds);

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) =>
      _ds.getUserProfile(uid);

  @override
  Future<int> countListings(String uid) => _ds.countListings(uid);

  @override
  Future<int> countSoldListings(String uid) => _ds.countSoldListings(uid);
}

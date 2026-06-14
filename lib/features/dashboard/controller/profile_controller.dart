import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/user/domain/repositories/i_user_repository.dart';

class ProfileController extends GetxController {
  final IUserRepository _userRepo;
  final IAuthRepository _authRepo;

  ProfileController(this._userRepo, this._authRepo);

  final RxInt totalListings = 0.obs;
  final RxInt soldListings = 0.obs;
  final RxInt boughtListings = 0.obs;
  final RxBool isLoadingCounts = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCountsValue();
  }

  Future<void> fetchCountsValue() async {
    try {
      isLoadingCounts.value = true;
      final uid = _authRepo.currentUser?.uid;
      if (uid == null) return;

      totalListings.value = await _userRepo.countListings(uid);
      soldListings.value = await _userRepo.countSoldListings(uid);
      boughtListings.value = 0; // placeholder — buy tracking not yet implemented
    } finally {
      isLoadingCounts.value = false;
    }
  }
}

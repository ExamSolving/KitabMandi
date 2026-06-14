import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/language_controller.dart';
import 'package:kitab_mandi/features/notification/controller/notification_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/core/controller/theme_controller.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kitab_mandi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:kitab_mandi/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:kitab_mandi/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:kitab_mandi/features/help_center/data/datasources/help_remote_datasource.dart';
import 'package:kitab_mandi/features/help_center/data/repositories/help_repository_impl.dart';
import 'package:kitab_mandi/features/help_center/domain/repositories/i_help_repository.dart';
import 'package:kitab_mandi/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:kitab_mandi/features/listing/data/repositories/listing_repository_impl.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:kitab_mandi/features/user/data/datasources/user_remote_datasource.dart';
import 'package:kitab_mandi/features/user/data/repositories/user_repository_impl.dart';
import 'package:kitab_mandi/features/user/domain/repositories/i_user_repository.dart';
import 'package:kitab_mandi/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:kitab_mandi/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:kitab_mandi/features/wishlist/domain/repositories/i_wishlist_repository.dart';

/// Root DI composition: registers everything that must survive the full
/// app session as permanent singletons.  Feature bindings do lazy-put for
/// screen-scoped controllers and simply Get.find<> the repos registered here.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Core controllers ────────────────────────────────────────────────────
    // ThemeController and LanguageController are pre-registered in main()
    // before runApp so the root Obx wrapper can access them immediately.
    // Guard here to avoid duplicate registration if InitialBinding reruns.
    if (!Get.isRegistered<ThemeController>()) {
      Get.put<ThemeController>(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<LanguageController>()) {
      Get.put<LanguageController>(LanguageController(), permanent: true);
    }
    Get.put<LocationController>(LocationController(), permanent: true);

    // ── Auth repository ─────────────────────────────────────────────────────
    Get.put<IAuthRepository>(
      AuthRepositoryImpl(AuthRemoteDataSource()),
      permanent: true,
    );

    // ── Listing repository ──────────────────────────────────────────────────
    Get.put<IListingRepository>(
      ListingRepositoryImpl(ListingRemoteDataSource()),
      permanent: true,
    );

    // ── Wishlist repository ─────────────────────────────────────────────────
    Get.put<IWishlistRepository>(
      WishlistRepositoryImpl(WishlistRemoteDataSource()),
      permanent: true,
    );

    // ── Chat repository ─────────────────────────────────────────────────────
    Get.put<IChatRepository>(
      ChatRepositoryImpl(ChatRemoteDataSource()),
      permanent: true,
    );

    // ── User repository ─────────────────────────────────────────────────────
    Get.put<IUserRepository>(
      UserRepositoryImpl(UserRemoteDataSource()),
      permanent: true,
    );

    // ── Help repository ─────────────────────────────────────────────────────
    Get.put<IHelpRepository>(
      HelpRepositoryImpl(HelpRemoteDataSource()),
      permanent: true,
    );

    // ── Auth controller (permanent — drives the auth-gate wrapper) ──────────
    Get.put<AuthController>(
      AuthController(Get.find<IAuthRepository>()),
      permanent: true,
    );

    // ── Notification controller (permanent — badge count visible from all screens) ──
    Get.put<NotificationController>(NotificationController(), permanent: true);
  }
}

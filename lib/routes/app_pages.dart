import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/binding/auth_binding.dart';
import 'package:kitab_mandi/features/profile_edit/controller/profile_edit_controller.dart';
import 'package:kitab_mandi/features/profile_edit/view/profile_edit_view.dart';
import 'package:kitab_mandi/features/auth/view/auth_view.dart';
import 'package:kitab_mandi/features/auth/view/email_verification_view.dart';
import 'package:kitab_mandi/features/auth/view/forgot_password_view.dart';
import 'package:kitab_mandi/features/dashboard/binding/chat_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/dashboard_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/home_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/profile_binding.dart';
import 'package:kitab_mandi/features/dashboard/view/chat_view.dart';
import 'package:kitab_mandi/features/dashboard/view/chat_room_view.dart';
import 'package:kitab_mandi/features/dashboard/view/my_ads_view.dart';
import 'package:kitab_mandi/features/help_center/binding/help_support_binding.dart';
import 'package:kitab_mandi/features/help_center/view/help_support_view.dart';
import 'package:kitab_mandi/features/notification/view/notification_view.dart';
import 'package:kitab_mandi/features/listing_details/binding/listing_details_binding.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/features/seller/binding/seller_binding.dart';
import 'package:kitab_mandi/features/wishlist/binding/wishlist_binding.dart';
import 'package:kitab_mandi/features/dashboard/view/dashboard_view.dart';
import 'package:kitab_mandi/features/seller/view/seller_listing_view.dart';
import 'package:kitab_mandi/features/splash/binding/splash_binding.dart';
import 'package:kitab_mandi/features/splash/view/splash_view.dart';
import 'package:kitab_mandi/features/subscription/view/subscription_view.dart';
import 'package:kitab_mandi/features/wishlist/view/wishlist_view.dart';
import 'package:kitab_mandi/features/wrapper/wrapper_view.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    //  Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.wrapper, page: () => const WrapperView()),
    // //  Auth
    GetPage(
      name: AppRoutes.auth,
      page: () => AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordView()),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => EmailVerificationView(email: Get.arguments as String? ?? ''),
    ),
    // //  Dashboard
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      bindings: [DashboardBinding(), HomeBinding(), ProfileBinding(), ChatBinding()],
    ),

    GetPage(
      name: AppRoutes.wishlist,
      page: () => WishlistView(),
      binding: WishlistBinding(),
    ),

    GetPage(
      name: AppRoutes.addListing,
      page: () => SellerListingView(),
      binding: SellerBinding(),
    ),
    GetPage(
      name: AppRoutes.myAds,
      page: () => MyAdsView(),
      // binding: MyAds(),
    ),
    GetPage(
      name: AppRoutes.listingDetailsView,
      page: () => ListingDetailsView(listing: Get.find(), docId: Get.find()),
      binding: ListingDetailsBinding(),
      // binding: MyAds(),
    ),
    GetPage(
      name: AppRoutes.chatView,
      page: () => ChatView(),
      binding: ChatBinding(),
      // binding: MyAds(),
    ),
    GetPage(
      name: AppRoutes.chatRoom,
      page: () => ChatRoomView(),
      // binding: Chat(),
      // binding: MyAds(),
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => HelpSupportView(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationView(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => ProfileEditView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileEditController(Get.find()));
      }),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionView(),
    ),
  ];
}

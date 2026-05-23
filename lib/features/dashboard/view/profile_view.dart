import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';
import 'package:kitab_mandi/core/controller/theme_controller.dart';
import 'package:kitab_mandi/core/services/share_service.dart';
import 'package:kitab_mandi/features/about_app/about_app_view.dart';
import 'package:kitab_mandi/features/about_app/terms_policies_view.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/profile_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_button.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final authCtrl = Get.find<AuthController>();
  final profileCtrl = Get.put(ProfileController());
  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  ///  SURFACES
  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _softSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF151821) : const Color(0xFFF6F7FB);
  }

  Color _mutedText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280);
  }

  Border _border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border.all(
      color: isDark ? Colors.transparent : const Color(0xFFE5E7EB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      ///  APP BAR (unchanged logic)
      appBar: AppBar(
        title: Text("Profile", style: AppTextStyles.heading2(context)),
        elevation: 0,
        backgroundColor: _background(context),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context, authCtrl),
            const SizedBox(height: 14),

            _buildStats(context),
            const SizedBox(height: 14),

            // _buildQuickActions(context),
            const SizedBox(height: 14),

            Obx(() => _themeSwitch(context, controller)),
            const SizedBox(height: 14),

            _buildSection(
              context,
              title: "Account",
              children: [
                _tile(context, Icons.book_outlined, "My Listings", () {
                  Get.toNamed(AppRoutes.myAds);
                }),
                // _tile(context, Icons.shopping_bag_outlined, "My Orders", () {}),
                _tile(context, Icons.favorite_border, "My Wishlist", () {
                  Get.toNamed(AppRoutes.wishlist);
                }),
              ],
            ),

            const SizedBox(height: 14),

            _buildSection(
              context,
              title: "Support",
              children: [
                _tile(context, Icons.help_outline, "Help & Support", () {
                  Get.toNamed(AppRoutes.helpSupport);
                }),
                _tile(context, Icons.share, "Share App", () {
                  ShareService.shareApp();
                  // Get.toNamed(AppRoutes.helpSupport);
                }),
                _tile(context, Icons.policy_outlined, "Terms & Policies", () {
                  Get.to(TermsPoliciesView());
                }),
                _tile(context, Icons.info_outline, "About App", () {
                  Get.to(AboutView());
                }),
              ],
            ),

            const SizedBox(height: 14),

            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  ///  PROFILE HEADER (clean + modern)
  Widget _buildProfileHeader(BuildContext context, AuthController ctrl) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(18),
        border: _border(context),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
            child: Icon(
              Icons.person,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authCtrl.userData.value?['name'] ?? 'NA',
                    style: AppTextStyles.title(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${'+91' + authCtrl.userData.value?['phone']}",
                    style: TextStyle(fontSize: 12, color: _mutedText(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authCtrl.userData.value?['email'] ?? 'NA',
                    style: TextStyle(fontSize: 12, color: _mutedText(context)),
                  ),
                ],
              ),
            ),
          ),

          Icon(
            Icons.edit,
            size: 18,
            color: theme.iconTheme.color?.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  /// 📊 STATS (modern compact cards)
  Widget _buildStats(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _statItem(
            context,
            profileCtrl.totalListings.value.toString(),
            "Listings",
          ),
          _statItem(context, profileCtrl.soldListings.value.toString(), "Sold"),
          _statItem(
            context,
            profileCtrl.boughtListings.value.toString(),
            "Bought",
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String count, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _softSurface(context),
          borderRadius: BorderRadius.circular(14),
          border: _border(context),
        ),
        child: Column(
          children: [
            Text(count, style: AppTextStyles.title(context)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }

  /// 🌗 THEME SWITCH (clean surface)
  Widget _themeSwitch(BuildContext context, ThemeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(14),
        border: _border(context),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text("Dark Mode", style: AppTextStyles.body(context)),
        value: controller.isDarkMode(context),
        onChanged: controller.toggleTheme,
      ),
    );
  }

  /// 📂 SECTION HEADER
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: _border(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle(context)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  /// 🔹 TILE (clean modern list item)
  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    Function()? onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, size: 20, color: theme.iconTheme.color),
      title: Text(title, style: AppTextStyles.body(context)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: theme.iconTheme.color?.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  /// 🚪 LOGOUT (modern minimal button)
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        backgroundColor: AppColors.secondaryDark,
        text: "Logout",
        onPressed: () {
          authCtrl.showLogoutDialog(context);
        },
      ),
    );
  }
}

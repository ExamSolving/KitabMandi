import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/controller/language_controller.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class AuthView extends StatelessWidget {
  AuthView({super.key});

  final AuthController controller = Get.find<AuthController>();
  final LanguageController langCtrl = Get.find<LanguageController>();

  Color _card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1D23)
          : Colors.white;

  Widget _prefix(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 10),
        Icon(icon, color: theme.iconTheme.color),
        const SizedBox(width: 10),
        Container(height: 45, width: 0.5, color: theme.dividerColor),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, bottom: 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.secondaryDark,
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                /// DECORATIVE ORBS
                Positioned(
                  top: -20,
                  left: -30,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: -20,
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                /// CENTERED LOGO + BRANDING
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo badge
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Image.asset("assets/splash.png"),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'app_name'.tr,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'app_tagline'.tr,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.78),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                /// LANGUAGE SWITCHER — top right absolute
                Positioned(
                  top: 0,
                  right: 12,
                  child: _LanguageSwitcher(langCtrl: langCtrl),
                ),
              ],
            ),
          ),

          /// FORM
          Expanded(
            child: Obx(
              () => SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      /// CARD
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _card(context),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            /// NAME (SIGNUP)
                            if (!controller.isLogin.value) ...[
                              AppTextField(
                                controller: controller.nameController,
                                hintText: 'name'.tr,
                                validator: controller.validateName,
                                prefixIcon: _prefix(context, Icons.person),
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                controller: controller.phoneController,
                                hintText: 'phone_number'.tr,
                                keyboardType: TextInputType.phone,
                                validator: controller.validatePhone,
                                prefixIcon: _prefix(context, Icons.call),
                              ),
                              const SizedBox(height: 16),
                            ],

                            /// EMAIL
                            AppTextField(
                              controller: controller.emailController,
                              hintText: 'email'.tr,
                              keyboardType: TextInputType.emailAddress,
                              validator: controller.validateEmail,
                              enabled:
                                  controller.isLogin.value ||
                                  !controller.isGoogleUser.value,
                              readOnly: controller.isGoogleUser.value,
                              prefixIcon: _prefix(context, Icons.email),
                            ),

                            const SizedBox(height: 16),

                            /// PASSWORD
                            if (!controller.isGoogleUser.value)
                              Obx(
                                () => AppTextField(
                                  controller: controller.passwordController,
                                  hintText: 'password'.tr,
                                  obscureText: controller.obscurePassword.value,
                                  validator: controller.validatePassword,
                                  prefixIcon: _prefix(context, Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: controller.togglePassword,
                                  ),
                                ),
                              ),

                            /// FORGOT PASSWORD
                            if (controller.isLogin.value &&
                                !controller.isGoogleUser.value)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    controller.clearAllFields();
                                    Get.toNamed(AppRoutes.forgotPassword);
                                  },
                                  child: Text('forgot_password'.tr),
                                ),
                              ),

                            const SizedBox(height: 20),

                            /// BUTTON
                            AppButton(
                              text: controller.isLogin.value
                                  ? 'login'.tr
                                  : controller.isGoogleUser.value
                                  ? 'continue_btn'.tr
                                  : 'signup'.tr,
                              isLoading: controller.isLoading.value,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (controller.formKey.currentState!
                                    .validate()) {
                                  controller.submit();
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// DIVIDER
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or'.tr,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// GOOGLE LOGIN
                      GestureDetector(
                        onTap: controller.signInWithGoogle,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: _card(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/google.png", height: 22),
                              const SizedBox(width: 12),
                              Text(
                                'continue_with_google'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// TOGGLE LOGIN/SIGNUP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isLogin.value
                                ? 'dont_have_account'.tr
                                : 'already_have_account'.tr,
                            style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: controller.toggleMode,
                            child: Text(
                              controller.isLogin.value
                                  ? 'signup'.tr
                                  : 'login'.tr,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// TERMS
                      Text(
                        'terms_agreement'.tr,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact language toggle shown in the auth header
class _LanguageSwitcher extends StatelessWidget {
  final LanguageController langCtrl;

  const _LanguageSwitcher({required this.langCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangBtn(
            label: 'EN',
            selected: langCtrl.isEnglish,
            onTap: () => langCtrl.changeLanguage('en'),
          ),
          const SizedBox(width: 4),
          _LangBtn(
            label: 'हिं',
            selected: langCtrl.isHindi,
            onTap: () => langCtrl.changeLanguage('hi'),
          ),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

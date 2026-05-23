import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_string.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class AuthView extends StatelessWidget {
  AuthView({super.key});

  final AuthController controller = Get.find<AuthController>();

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
        Container(
          height: 45,
          width: 0.5,
          color: theme.dividerColor, //  DARK/LIGHT SAFE
        ),
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
          ///  HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.secondaryDark,
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Image.asset("assets/splash.png", height: 60),
                const SizedBox(height: 10),
                const Text(
                  "KitabMandi",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Buy • Sell • Save • Learn",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          /// 📄 FORM
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
                      ///  CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _card(context),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ///  NAME (SIGNUP)
                            if (!controller.isLogin.value) ...[
                              AppTextField(
                                controller: controller.nameController,
                                hintText: AppStrings.name,
                                validator: controller.validateName,
                                prefixIcon: _prefix(context, Icons.person),
                              ),
                              const SizedBox(height: 16),

                              ///  PHONE
                              AppTextField(
                                controller: controller.phoneController,
                                hintText: "Enter phone number",
                                keyboardType: TextInputType.phone,
                                validator: controller.validatePhone,
                                prefixIcon: _prefix(context, Icons.call),
                              ),
                              const SizedBox(height: 16),
                            ],

                            ///  EMAIL
                            AppTextField(
                              controller: controller.emailController,
                              hintText: AppStrings.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: controller.validateEmail,
                              enabled:
                                  controller.isLogin.value ||
                                  !controller.isGoogleUser.value,
                              readOnly: controller.isGoogleUser.value,
                              prefixIcon: _prefix(context, Icons.email),
                            ),

                            const SizedBox(height: 16),

                            ///  PASSWORD (HIDE FOR GOOGLE USER)
                            if (!controller.isGoogleUser.value)
                              Obx(
                                () => AppTextField(
                                  controller: controller.passwordController,
                                  hintText: AppStrings.password,
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

                            ///  FORGOT PASSWORD
                            if (controller.isLogin.value &&
                                !controller.isGoogleUser.value)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    controller.clearAllFields();
                                    Get.toNamed(AppRoutes.forgotPassword);
                                  },
                                  child: const Text("Forgot Password?"),
                                ),
                              ),

                            const SizedBox(height: 20),

                            ///  BUTTON
                            AppButton(
                              text: controller.isLogin.value
                                  ? AppStrings.login
                                  : controller.isGoogleUser.value
                                  ? "Continue"
                                  : AppStrings.signup,
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

                      const SizedBox(height: 25),

                      ///  DIVIDER
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.dividerColor)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR"),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// 🌐 GOOGLE LOGIN
                      GestureDetector(
                        onTap: controller.signInWithGoogle,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _card(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/google.png", height: 22),
                              const SizedBox(width: 12),
                              Text(
                                "Continue with Google",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// 🔁 TOGGLE LOGIN/SIGNUP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isLogin.value
                                ? "Don't have an account? "
                                : "Already have an account? ",
                          ),
                          GestureDetector(
                            onTap: controller.toggleMode,
                            child: Text(
                              controller.isLogin.value ? "Sign Up" : "Login",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// 📜 TERMS
                      Text(
                        "By continuing, you agree to our Terms & Privacy Policy",
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
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

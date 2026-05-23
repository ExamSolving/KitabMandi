import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_string.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final controller = Get.put(AuthController());
  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: _background(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Text(
              "Reset Password 🔐",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 10),

            Text(
              "Enter your registered email to receive a password reset link.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            ///  EMAIL
            AppTextField(
              controller: controller.forgotEmailController,
              hintText: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              enabled:
                  controller.isLogin.value || !controller.isGoogleUser.value,
              readOnly: controller.isGoogleUser.value,
              prefixIcon: _prefix(context, Icons.email),
            ),

            const SizedBox(height: 30),

            /// 🔘 BUTTON
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.forgotPassword,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text("Send Reset Link"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final controller = Get.find<AuthController>();

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
    return Scaffold(
      appBar: AppBar(
        title: Text('reset_password'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'reset_password_title'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'reset_password_subtitle'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            AppTextField(
              controller: controller.forgotEmailController,
              hintText: 'email'.tr,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              enabled: controller.isLogin.value || !controller.isGoogleUser.value,
              readOnly: controller.isGoogleUser.value,
              prefixIcon: _prefix(context, Icons.email),
            ),
            const SizedBox(height: 30),
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
                      : Text('send_reset_link'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

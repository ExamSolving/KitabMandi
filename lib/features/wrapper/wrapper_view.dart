import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/view/auth_view.dart';
import 'package:kitab_mandi/features/dashboard/view/dashboard_view.dart';

class WrapperView extends StatelessWidget {
  const WrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      // Still waiting for the first Firebase auth event on app start
      if (auth.isCheckingAuth.value) {
        return const _SplashLoader();
      }

      final data = auth.userData.value;

      // Not logged in
      if (data == null) {
        return AuthView();
      }

      // Logged in but phone is missing — user never completed signup.
      // Switch to signup mode so they see the profile-completion form,
      // not the login form (which would silently loop after re-authenticating).
      if (data['phone'] == null || data['phone'].toString().isEmpty) {
        if (auth.isLogin.value) {
          // Schedule outside build to avoid setState-during-build warnings
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => auth.isLogin.value = false,
          );
        }
        return AuthView();
      }

      // Fully authenticated
      return const DashboardView();
    });
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset('assets/splash.png'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

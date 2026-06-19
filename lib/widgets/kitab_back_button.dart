import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';

class KitabBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const KitabBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        (onTap ?? Get.back)();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.08),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : AppColors.primary.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: isDark ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

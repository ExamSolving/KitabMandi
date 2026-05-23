import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final bool readOnly;

  /// 🔥 NEW FEATURES
  final bool isBorderless;
  final EdgeInsetsGeometry? contentPadding;

  /// ✨ ADDED (IMPORTANT)
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,

    this.isBorderless = false,
    this.contentPadding,

    /// NEW
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged, // ✅ ADDED HERE

      cursorColor: theme.colorScheme.primary,

      style: AppTextStyles.body(context).copyWith(color: textColor),

      decoration: InputDecoration(
        isDense: true,

        hintText: hintText,
        hintStyle: AppTextStyles.subtitle(
          context,
        ).copyWith(color: theme.hintColor),

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        filled: true,
        fillColor: theme.cardColor,

        contentPadding:
            contentPadding ??
            (isBorderless
                ? const EdgeInsets.symmetric(vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),

        border: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),

        enabledBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),

        focusedBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.2,
                ),
              ),

        errorBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),

        focusedErrorBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.2,
                ),
              ),

        errorStyle: AppTextStyles.caption(
          context,
        ).copyWith(color: theme.colorScheme.error),
      ),

      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
    );
  }
}

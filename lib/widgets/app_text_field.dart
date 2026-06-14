import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_spacing.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';

/// Consistent text input for KitabMandi.
///
/// Behaviour:
/// - Filled background using the theme's card surface.
/// - No border when unfocused; subtle primary border when focused.
/// - Borderless mode for inline inputs (e.g. search).
///
/// ```dart
/// AppTextField(controller: ctrl, hintText: 'Email')
/// AppTextField(controller: ctrl, hintText: 'Search', isBorderless: true,
///              prefixIcon: const Icon(Icons.search))
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.formatters,
    this.isBorderless = false,
    this.contentPadding,
    this.onChanged,
    this.onTap,
    this.textInputAction,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hintText;

  /// Optional floating label shown above the field when focused / filled.
  final String? label;

  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? formatters;

  /// Removes all borders and background — use inside AppBars / search bars.
  final bool isBorderless;

  final EdgeInsetsGeometry? contentPadding;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fillColor = isBorderless
        ? Colors.transparent
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant);

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;

    OutlineInputBorder makeBorder(Color? sideColor, {double width = 0}) =>
        OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: sideColor != null
              ? BorderSide(color: sideColor, width: width)
              : BorderSide.none,
        );

    final defaultPadding = contentPadding ??
        (isBorderless
            ? const EdgeInsets.symmetric(vertical: AppSpacing.x10)
            : const EdgeInsets.symmetric(
                horizontal: AppSpacing.inputPaddingH,
                vertical: AppSpacing.inputPaddingV,
              ));

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: formatters,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      cursorColor: primaryColor,
      cursorRadius: const Radius.circular(2),
      cursorWidth: 1.8,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.4,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: hintColor,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
        hintText: label == null ? hintText : null,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: hintColor,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(
                  color: hintColor,
                  size: AppSpacing.iconMd,
                ),
                child: prefixIcon!,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? IconTheme(
                data: IconThemeData(
                  color: hintColor,
                  size: AppSpacing.iconMd,
                ),
                child: suffixIcon!,
              )
            : null,
        filled: true,
        fillColor: fillColor,
        contentPadding: defaultPadding,
        border: isBorderless ? InputBorder.none : makeBorder(null),
        enabledBorder: isBorderless ? InputBorder.none : makeBorder(null),
        focusedBorder: isBorderless
            ? InputBorder.none
            : makeBorder(primaryColor, width: 1.5),
        errorBorder: isBorderless ? InputBorder.none : makeBorder(errorColor, width: 1.0),
        focusedErrorBorder: isBorderless
            ? InputBorder.none
            : makeBorder(errorColor, width: 1.5),
        disabledBorder: isBorderless ? InputBorder.none : makeBorder(null),
        errorStyle: AppTextStyles.caption(context).copyWith(color: errorColor, height: 1.3),
        errorMaxLines: 2,
      ),
      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
    );
  }
}

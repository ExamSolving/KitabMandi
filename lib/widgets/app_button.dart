import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_spacing.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';
import 'package:kitab_mandi/core/utils/responsive.dart';

enum _ButtonVariant { filled, outlined, ghost }

/// Primary CTA button.
///
/// - [backgroundColor] defaults to [AppColors.primary].
/// - When [isLoading] is true the button is disabled and shows a spinner.
/// - Width always fills available space; height adapts to the screen.
///
/// ```dart
/// AppButton(text: 'Login', onPressed: _handleLogin)
/// AppButton.outlined(text: 'Cancel', onPressed: Get.back)
/// AppButton.ghost(text: 'Skip', onPressed: _skip)
/// ```
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leadingIcon;
  final double? width;
  final _ButtonVariant _variant;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.leadingIcon,
    this.width,
  }) : _variant = _ButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.leadingIcon,
    this.width,
  })  : backgroundColor = null,
        _variant = _ButtonVariant.outlined;

  const AppButton.ghost({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.leadingIcon,
    this.width,
  })  : backgroundColor = null,
        _variant = _ButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkPrimary : AppColors.primary;
    final bgColor = backgroundColor ?? defaultBg;

    final autoText = bgColor.computeLuminance() > 0.45
        ? Colors.black87
        : Colors.white;
    final resolvedText = textColor ?? autoText;

    final height = Responsive.buttonHeight(context);
    final resolvedWidth = width ?? double.infinity;

    return SizedBox(
      width: resolvedWidth,
      height: height,
      child: switch (_variant) {
        _ButtonVariant.filled => _FilledButton(
            text: text,
            onPressed: isLoading ? null : onPressed,
            bgColor: bgColor,
            textColor: resolvedText,
            isLoading: isLoading,
            leadingIcon: leadingIcon,
          ),
        _ButtonVariant.outlined => _OutlinedButton(
            text: text,
            onPressed: isLoading ? null : onPressed,
            textColor: textColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary),
            isLoading: isLoading,
            leadingIcon: leadingIcon,
          ),
        _ButtonVariant.ghost => _GhostButton(
            text: text,
            onPressed: isLoading ? null : onPressed,
            textColor: textColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary),
            isLoading: isLoading,
            leadingIcon: leadingIcon,
          ),
      },
    );
  }
}

// ── Filled ─────────────────────────────────────────────────────────────────────

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.text,
    required this.onPressed,
    required this.bgColor,
    required this.textColor,
    required this.isLoading,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color textColor;
  final bool isLoading;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.buttonBR,
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.buttonBR,
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Center(child: _content(context)),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }

    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon!,
          const SizedBox(width: AppSpacing.x8),
          Text(text, style: AppTextStyles.button(context).copyWith(color: textColor)),
        ],
      );
    }

    return Text(text, style: AppTextStyles.button(context).copyWith(color: textColor));
  }
}

// ── Outlined ───────────────────────────────────────────────────────────────────

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.text,
    required this.onPressed,
    required this.textColor,
    required this.isLoading,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final bool isLoading;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onPressed == null ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: AppRadius.buttonBR,
            border: Border.all(color: textColor, width: 1.5),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.buttonBR,
            splashColor: textColor.withValues(alpha: 0.08),
            highlightColor: textColor.withValues(alpha: 0.04),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: textColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon!,
                          const SizedBox(width: AppSpacing.x8),
                        ],
                        Text(
                          text,
                          style: AppTextStyles.button(context).copyWith(color: textColor),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ghost (text only) ──────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.text,
    required this.onPressed,
    required this.textColor,
    required this.isLoading,
    this.leadingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final bool isLoading;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x16,
          vertical: AppSpacing.x8,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBR),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: AppSpacing.x6),
                ],
                Text(
                  text,
                  style: AppTextStyles.button(context).copyWith(color: textColor),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _iconBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2A2F3A) : const Color(0xFFF3F4F6);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: Container(
        height: 52,

        decoration: BoxDecoration(
          color: _surface(context),

          borderRadius: BorderRadius.circular(18),

          /// 🔥 THICKER + PREMIUM BORDER
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.35 : 0.08,
              ),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          children: [
            const SizedBox(width: 10),

            /// 🔍 SEARCH ICON (PREMIUM BACKGROUND)
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _iconBg(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.search,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 10),

            /// TEXT FIELD
            Expanded(
              child: AppTextField(
                controller: controller,
                hintText: "Search books, notes, publisher...",
                isBorderless: true,
                onChanged: onChanged,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            /// 🔧 FILTER ICON (PREMIUM CHIP STYLE)
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: _iconBg(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFE5E7EB),
                  ),
                ),

                child: Icon(
                  Icons.tune,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

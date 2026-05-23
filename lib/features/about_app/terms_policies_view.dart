import 'package:flutter/material.dart';

class TermsPoliciesView extends StatelessWidget {
  const TermsPoliciesView({super.key});
  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Terms & Policies"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _background(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            ///  HEADER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 50,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "KitabMandi Policies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Please read carefully before using the app",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 TERMS SECTION
            _policyCard(
              context,
              title: "1. User Agreement",
              content:
                  "By using KitabMandi, you agree to use the platform responsibly. "
                  "Users must not upload fake or illegal listings.",
            ),

            _policyCard(
              context,
              title: "2. Buying & Selling",
              content:
                  "KitabMandi acts as a platform connecting buyers and sellers. "
                  "We are not responsible for product quality or transactions.",
            ),

            _policyCard(
              context,
              title: "3. Chat & Communication",
              content:
                  "Users can chat freely regarding listings. "
                  "Abusive or spam messages are strictly prohibited.",
            ),

            _policyCard(
              context,
              title: "4. Privacy Policy",
              content:
                  "We collect basic user data like name, email, and location "
                  "to improve user experience and recommendations.",
            ),

            _policyCard(
              context,
              title: "5. Account Safety",
              content:
                  "Users are responsible for maintaining account security. "
                  "Do not share login credentials with others.",
            ),

            _policyCard(
              context,
              title: "6. Updates",
              content:
                  "We may update policies anytime. Continued usage means acceptance of changes.",
            ),

            const SizedBox(height: 20),

            /// 🔥 FOOTER
            Text(
              "© 2026 KitabMandi • All rights reserved",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔥 POLICY CARD WIDGET
  Widget _policyCard(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          /// CONTENT
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

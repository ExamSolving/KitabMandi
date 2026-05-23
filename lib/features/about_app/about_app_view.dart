import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});
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
        title: const Text("About KitabMandi"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _background(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔥 LOGO + NAME CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  /// LOGO
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                    ),
                    child: Image.asset('assets/logo.png'),
                  ),

                  const SizedBox(height: 12),

                  /// NAME
                  const Text(
                    "KitabMandi",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  /// TAGLINE
                  Text(
                    "Buy & Sell Books Easily 📚",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 ABOUT
            _premiumCard(
              context,
              icon: Icons.info_outline,
              title: "About App",
              content:
                  "KitabMandi is a smart marketplace for students to buy and sell second-hand books easily. "
                  "Save money, reuse books, and connect with buyers & sellers near you.",
            ),

            /// 🔥 FEATURES
            _premiumCard(
              context,
              icon: Icons.star_border,
              title: "Features",
              content:
                  "• Buy & Sell Books\n"
                  "• Real-time Chat\n"
                  "• Location-based Listings\n"
                  "• Easy Upload\n"
                  "• Secure Login",
            ),

            /// 🔥 VERSION
            _premiumCard(
              context,
              icon: Icons.system_update,
              title: "App Version",
              content: "Version 1.0.0",
            ),

            /// 🔥 CONTACT
            _premiumCard(
              context,
              icon: Icons.contact_mail_outlined,
              title: "Contact Us",
              content: "support@kitabmandi.com\nwww.kitabmandi.in",
            ),

            const SizedBox(height: 20),

            /// FOOTER
            Text(
              "© 2026 KitabMandi",
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 🔥 PREMIUM CARD COMPONENT
  Widget _premiumCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).iconTheme.color),
          ),

          const SizedBox(width: 12),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                /// CONTENT
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

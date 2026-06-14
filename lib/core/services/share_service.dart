import 'package:share_plus/share_plus.dart';

class ShareService {
  static const String appName = "KitabMandi";

  static const String appLink =
      "https://play.google.com/store/apps/details?id=com.appvora.kitabmandi";
  // 👉 replace with your real package name

  static void shareApp() {
    final String message =
        """
📚 $appName – Buy & Sell Books Easily!

🚀 India's smart marketplace for books & study materials.

✨ What you get:
• 📖 Buy & Sell Used Books
• 💰 Best Prices from Local Sellers
• 📦 Easy Chat with Buyers & Sellers
• 🔔 Instant Notifications
• 📍 Location-based Listings

🔥 Join thousands of students already using $appName!

📲 Download now:
$appLink

💙 Share with your friends & help them save money on books!
""";

    Share.share(message, subject: "$appName - Buy & Sell Books Easily");
  }
}

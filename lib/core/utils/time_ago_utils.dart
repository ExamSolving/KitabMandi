class TimeAgoUtil {
  static String timeAgo(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // 🔥 Just now (< 1 min)
    if (difference.inSeconds < 60) {
      return "Just now";
    }

    // 🔥 Hours (up to 6 hours)
    if (difference.inHours < 6 && _isSameDay(dateTime, now)) {
      final h = difference.inHours;
      return "$h hour${h > 1 ? "s" : ""} ago";
    }

    // 🔥 Today (after 6 hours but same day)
    if (_isSameDay(dateTime, now)) {
      return "Today";
    }

    // 🔥 Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dateTime, yesterday)) {
      return "Yesterday";
    }

    // 🔥 Same year → 8 May
    if (dateTime.year == now.year) {
      return "${dateTime.day} ${_monthName(dateTime.month)}";
    }

    // 🔥 Different year → 8 May 2024
    return "${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}";
  }

  /// ✅ Same day check
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// ✅ Month names
  static String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';

/// Thin Firestore wrapper for user subscription state.
/// All methods are static — no controller / singleton required.
class SubscriptionService {
  static final _fs = FirebaseFirestore.instance;

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getSubscription(String uid) async {
    final doc = await _fs.collection('users').doc(uid).get();
    return doc.data()?['subscription'] as Map<String, dynamic>?;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<void> save(
    String uid, {
    required String plan,
    required String paymentId,
    required int amountPaise,
  }) async {
    final isAnnual = plan.contains('annual');
    final expiresAt = DateTime.now().add(
      Duration(days: isAnnual ? 365 : 30),
    );

    await _fs.collection('users').doc(uid).update({
      'subscription': {
        'plan': plan,
        'status': 'active',
        'paymentId': paymentId,
        'amountPaise': amountPaise,
        'startedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      },
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool isActive(Map<String, dynamic>? sub) {
    if (sub == null || sub['status'] != 'active') return false;
    final raw = sub['expiresAt'];
    if (raw == null) return false;
    return (raw as Timestamp).toDate().isAfter(DateTime.now());
  }

  static String getPlan(Map<String, dynamic>? sub) =>
      sub?['plan'] as String? ?? RazorpayConfig.planFree;

  static String planLabel(String planKey) {
    switch (planKey) {
      case RazorpayConfig.planPlusMonthly:
        return 'Plus (Monthly)';
      case RazorpayConfig.planPlusAnnual:
        return 'Plus (Annual)';
      case RazorpayConfig.planProMonthly:
        return 'Pro (Monthly)';
      case RazorpayConfig.planProAnnual:
        return 'Pro (Annual)';
      default:
        return 'Free';
    }
  }

  /// Returns true when the user may create a new listing.
  /// Paid users have no limit; free users are capped at [RazorpayConfig.freeListingLimit].
  static bool canPost(Map<String, dynamic>? sub, int activeListings) {
    if (isActive(sub) && getPlan(sub) != RazorpayConfig.planFree) return true;
    return activeListings < RazorpayConfig.freeListingLimit;
  }
}

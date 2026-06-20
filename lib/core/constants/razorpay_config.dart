/// Centralised Razorpay constants.
/// Swap [keyId] for the live key before releasing to production.
class RazorpayConfig {
  RazorpayConfig._();

  // ── Keys ─────────────────────────────────────────────────────────────────
  // Test key — replace with rzp_live_… for production.
  static const String keyId = 'rzp_test_T3YACi92TIDCTL';
  static const String appName = 'KitabMandi';

  // ── Prices (in paise — ₹1 = 100 paise) ──────────────────────────────────
  static const int plusMonthly = 7900; // ₹79  / month
  static const int proMonthly = 14900; // ₹149 / month
  static const int plusAnnual =
      69900; // ₹699  / year  (~₹58.25/month, save 26%)
  static const int proAnnual =
      119900; // ₹1,199 / year (~₹99.92/month, save 33%)

  // ── Plan keys stored in Firestore ────────────────────────────────────────
  static const String planFree = 'free';
  static const String planPlusMonthly = 'plus_monthly';
  static const String planPlusAnnual = 'plus_annual';
  static const String planProMonthly = 'pro_monthly';
  static const String planProAnnual = 'pro_annual';

  // ── Free tier ─────────────────────────────────────────────────────────────
  // Free users can have at most this many active (non-sold) listings.
  static const int freeListingLimit = 2;
}

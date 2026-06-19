/// Centralised Razorpay constants.
/// Swap [keyId] for the live key before releasing to production.
class RazorpayConfig {
  RazorpayConfig._();

  // ── Keys ─────────────────────────────────────────────────────────────────
  // Test key — replace with rzp_live_… for production.
  static const String keyId = 'rzp_test_T3YACi92TIDCTL';
  static const String appName = 'KitabMandi';

  // ── Prices (in paise — ₹1 = 100 paise) ──────────────────────────────────
  static const int plusMonthly = 2900;  // ₹29 / month
  static const int proMonthly  = 4900;  // ₹49 / month
  static const int plusAnnual  = 24900; // ₹249 / year  (~₹20.75/month)
  static const int proAnnual   = 39900; // ₹399 / year  (~₹33.25/month)

  // ── Plan keys stored in Firestore ────────────────────────────────────────
  static const String planFree        = 'free';
  static const String planPlusMonthly = 'plus_monthly';
  static const String planPlusAnnual  = 'plus_annual';
  static const String planProMonthly  = 'pro_monthly';
  static const String planProAnnual   = 'pro_annual';

  // ── Free tier ─────────────────────────────────────────────────────────────
  // Free users can have at most this many active (non-sold) listings.
  static const int freeListingLimit = 2;
}

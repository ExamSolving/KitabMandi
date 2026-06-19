import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});
  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  late final Razorpay _rp;
  bool _annual = false;
  bool _paying = false;
  String? _activePlanKey;
  DateTime? _expiresAt;
  bool _loading = true;

  // The plan the user is in the middle of purchasing
  String? _pendingPlan;
  int? _pendingAmount;

  @override
  void initState() {
    super.initState();
    _rp = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _loadSub();
  }

  @override
  void dispose() {
    _rp.clear();
    super.dispose();
  }

  Future<void> _loadSub() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    final sub = await SubscriptionService.getSubscription(uid);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _activePlanKey = SubscriptionService.getPlan(sub);
      if (sub != null && sub['expiresAt'] != null) {
        _expiresAt = (sub['expiresAt'] as Timestamp).toDate();
      }
    });
  }

  void _pay(String planKey, int amountPaise) {
    if (_paying) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _pendingPlan   = planKey;
    _pendingAmount = amountPaise;

    final authCtrl = Get.find<AuthController>();
    final userData = authCtrl.userData.value;

    final options = <String, dynamic>{
      'key': RazorpayConfig.keyId,
      'amount': amountPaise,
      'currency': 'INR',
      'name': RazorpayConfig.appName,
      'description': SubscriptionService.planLabel(planKey),
      'prefill': {
        'email': user.email ?? '',
        'contact': userData?['phone'] as String? ?? '',
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': false,
        'emi': false,
        'paylater': false,
      },
      'theme': {'color': '#1B5E20'},
    };

    setState(() => _paying = true);
    try {
      _rp.open(options);
    } catch (e) {
      setState(() => _paying = false);
    }
  }

  void _onSuccess(PaymentSuccessResponse response) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _pendingPlan == null || _pendingAmount == null) return;

    try {
      await SubscriptionService.save(
        uid,
        plan: _pendingPlan!,
        paymentId: response.paymentId ?? '',
        amountPaise: _pendingAmount!,
      );
      // Refresh AuthController so the rest of the app sees the new plan.
      await Get.find<AuthController>().fetchUserData();
      if (!mounted) return;
      await _loadSub();
      _showSuccessSheet(_pendingPlan!);
    } catch (_) {
      _showErrorSheet(
        title: 'Subscription Not Saved',
        message:
            'Your payment went through but we couldn\'t activate your plan. Please contact support with your payment ID.',
        isWarning: true,
        onRetry: null,
      );
    } finally {
      if (mounted) setState(() => _paying = false);
      _pendingPlan   = null;
      _pendingAmount = null;
    }
  }

  void _onError(PaymentFailureResponse response) {
    if (mounted) setState(() => _paying = false);
    final plan   = _pendingPlan;
    final amount = _pendingAmount;
    _pendingPlan   = null;
    _pendingAmount = null;
    _showErrorSheet(
      title: 'Payment Failed',
      message: response.message ?? 'Payment failed. Please try again.',
      isWarning: false,
      onRetry: (plan != null && amount != null)
          ? () {
              Navigator.pop(context);
              _pay(plan, amount);
            }
          : null,
    );
  }

  void _showErrorSheet({
    required String title,
    required String message,
    required bool isWarning,
    VoidCallback? onRetry,
  }) {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ErrorSheet(
        title: title,
        message: message,
        isDark: isDark,
        isWarning: isWarning,
        onRetry: onRetry,
      ),
    );
  }

  void _showSuccessSheet(String planKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(planKey: planKey, isDark: isDark),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF4F6FA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Upgrade Plan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _CurrentPlanBanner(
                  planKey: _activePlanKey ?? RazorpayConfig.planFree,
                  expiresAt: _expiresAt,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // ── Billing toggle ──────────────────────────────────────────
                _BillingToggle(
                  annual: _annual,
                  onChanged: (v) => setState(() => _annual = v),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // ── Plan cards ──────────────────────────────────────────────
                _PlanCard(
                  title: 'Free',
                  price: '₹0',
                  period: 'forever',
                  color: Colors.grey,
                  features: const [
                    '2 active listings',
                    'Basic chat',
                    'Standard visibility',
                  ],
                  isCurrent: _activePlanKey == RazorpayConfig.planFree ||
                      _activePlanKey == null,
                  isDark: isDark,
                  isPopular: false,
                  onTap: null,
                  paying: false,
                ),
                const SizedBox(height: 14),

                _PlanCard(
                  title: 'Plus',
                  price: _annual ? '₹249' : '₹29',
                  period: _annual ? '/year  (~₹20.75/mo)' : '/month',
                  color: AppColors.primary,
                  features: const [
                    'Unlimited listings',
                    'All chat features',
                    'Priority visibility',
                  ],
                  isCurrent: _activePlanKey == (_annual
                      ? RazorpayConfig.planPlusAnnual
                      : RazorpayConfig.planPlusMonthly),
                  isDark: isDark,
                  isPopular: true,
                  paying: _paying &&
                      _pendingPlan == (_annual
                          ? RazorpayConfig.planPlusAnnual
                          : RazorpayConfig.planPlusMonthly),
                  onTap: () => _pay(
                    _annual
                        ? RazorpayConfig.planPlusAnnual
                        : RazorpayConfig.planPlusMonthly,
                    _annual
                        ? RazorpayConfig.plusAnnual
                        : RazorpayConfig.plusMonthly,
                  ),
                ),
                const SizedBox(height: 14),

                _PlanCard(
                  title: 'Pro',
                  price: _annual ? '₹399' : '₹49',
                  period: _annual ? '/year  (~₹33.25/mo)' : '/month',
                  color: const Color(0xFFF57C00),
                  features: const [
                    'Everything in Plus',
                    '3 featured boosts/month',
                    'Trusted Seller badge',
                  ],
                  isCurrent: _activePlanKey == (_annual
                      ? RazorpayConfig.planProAnnual
                      : RazorpayConfig.planProMonthly),
                  isDark: isDark,
                  isPopular: false,
                  paying: _paying &&
                      _pendingPlan == (_annual
                          ? RazorpayConfig.planProAnnual
                          : RazorpayConfig.planProMonthly),
                  onTap: () => _pay(
                    _annual
                        ? RazorpayConfig.planProAnnual
                        : RazorpayConfig.planProMonthly,
                    _annual
                        ? RazorpayConfig.proAnnual
                        : RazorpayConfig.proMonthly,
                  ),
                ),

                const SizedBox(height: 28),
                _DisclaimerText(isDark: isDark),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current plan banner
// ─────────────────────────────────────────────────────────────────────────────
class _CurrentPlanBanner extends StatelessWidget {
  final String planKey;
  final DateTime? expiresAt;
  final bool isDark;

  const _CurrentPlanBanner({
    required this.planKey,
    required this.expiresAt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = planKey == RazorpayConfig.planFree;
    final bg = isFree
        ? (isDark ? const Color(0xFF1A1D23) : Colors.white)
        : AppColors.primary.withValues(alpha: 0.1);
    final border = isFree
        ? (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.07))
        : AppColors.primary.withValues(alpha: 0.3);

    String subtitle;
    if (isFree) {
      subtitle = 'You can post up to ${RazorpayConfig.freeListingLimit} listings. Upgrade to post more.';
    } else if (expiresAt != null) {
      final d = expiresAt!;
      subtitle = 'Active until ${d.day}/${d.month}/${d.year}';
    } else {
      subtitle = 'Subscription active';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFree
                  ? Colors.grey.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              isFree ? Icons.person_outline_rounded : Icons.verified_rounded,
              color: isFree ? Colors.grey : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${SubscriptionService.planLabel(planKey)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
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

// ─────────────────────────────────────────────────────────────────────────────
// Monthly / Annual toggle
// ─────────────────────────────────────────────────────────────────────────────
class _BillingToggle extends StatelessWidget {
  final bool annual;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _BillingToggle({
    required this.annual,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          _Tab(label: 'Monthly', selected: !annual, onTap: () => onChanged(false), isDark: isDark),
          _Tab(label: 'Annual  🎉 Save ~28%', selected: annual, onTap: () => onChanged(true), isDark: isDark),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card
// ─────────────────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final Color color;
  final List<String> features;
  final bool isCurrent;
  final bool isPopular;
  final bool isDark;
  final bool paying;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    required this.isCurrent,
    required this.isPopular,
    required this.isDark,
    required this.paying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final borderColor = isCurrent
        ? color.withValues(alpha: 0.6)
        : (isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.06));

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isCurrent ? 1.5 : 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isPopular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Most Popular',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Features
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (onTap != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paying ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: paying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isCurrent ? 'Renew Plan' : 'Get $title',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Disclaimer
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerText extends StatelessWidget {
  final bool isDark;
  const _DisclaimerText({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Subscriptions are non-refundable. Plans auto-expire after the billing period — there is no automatic renewal. All prices are inclusive of taxes.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        height: 1.6,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment error bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorSheet extends StatelessWidget {
  final String title;
  final String message;
  final bool isDark;
  final bool isWarning;
  final VoidCallback? onRetry;

  const _ErrorSheet({
    required this.title,
    required this.message,
    required this.isDark,
    required this.isWarning,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1C1F28) : Colors.white;
    final iconColor = isWarning ? const Color(0xFFF57C00) : Colors.red.shade600;
    final iconBg = isWarning
        ? const Color(0xFFF57C00).withValues(alpha: 0.12)
        : Colors.red.shade600.withValues(alpha: 0.12);
    final iconData =
        isWarning ? Icons.warning_amber_rounded : Icons.error_outline_rounded;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
            child: Icon(iconData, color: iconColor, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          if (onRetry != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment success bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessSheet extends StatelessWidget {
  final String planKey;
  final bool isDark;
  const _SuccessSheet({required this.planKey, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1C1F28) : Colors.white;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re now on the ${SubscriptionService.planLabel(planKey)} plan. Enjoy unlimited listings!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

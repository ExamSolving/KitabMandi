import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/widgets/kitab_shimmer.dart';
import 'package:kitab_mandi/core/controller/language_controller.dart';
import 'package:kitab_mandi/core/controller/theme_controller.dart';
import 'package:kitab_mandi/core/services/share_service.dart';
import 'package:kitab_mandi/core/services/update_service.dart';
import 'package:kitab_mandi/features/about_app/about_app_view.dart';
import 'package:kitab_mandi/features/about_app/terms_policies_view.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/profile_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/notification_bell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileView — collapsible hero + floating stats card + card list layout
// ─────────────────────────────────────────────────────────────────────────────
class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final authCtrl = Get.find<AuthController>();
  final profileCtrl = Get.find<ProfileController>();
  final langCtrl = Get.find<LanguageController>();

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1F28) : Colors.white;
    final bgColor = isDark ? const Color(0xFF0E1117) : const Color(0xFFF1F3F8);
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsible hero ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 272,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1B5E20),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actions: [const NotificationBell(), const SizedBox(width: 8)],
            // Collapsed state shows just the name
            title: Obx(() {
              final name =
                  authCtrl.userData.value?['name'] as String? ?? 'profile'.tr;
              return Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              );
            }),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground],
              background: _ProfileHeroBg(authCtrl: authCtrl),
            ),
          ),

          // ── Stats floating card ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Obx(() {
                if (profileCtrl.isLoadingCounts.value) {
                  return _StatsCardShimmer(isDark: isDark, cardBg: cardBg);
                }
                return _StatsCard(
                  listings: profileCtrl.totalListings.value,
                  sold: profileCtrl.soldListings.value,
                  bought: profileCtrl.boughtListings.value,
                  isDark: isDark,
                  cardBg: cardBg,
                );
              }),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── My Activity ──────────────────────────────────────
                  _SectionHead(label: 'my_activity'.tr.toUpperCase(), theme: theme),
                  const SizedBox(height: 10),
                  Obx(
                    () => _ActivityRow(
                      listingCount: profileCtrl.totalListings.value,
                      isDark: isDark,
                      cardBg: cardBg,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Preferences ───────────────────────────────────────
                  _SectionHead(label: 'preferences'.tr.toUpperCase(), theme: theme),
                  const SizedBox(height: 10),
                  _PrefsCard(
                    themeCtrl: themeCtrl,
                    langCtrl: langCtrl,
                    isDark: isDark,
                    theme: theme,
                    cardBg: cardBg,
                  ),
                  const SizedBox(height: 28),

                  // ── Support ───────────────────────────────────────────
                  _SectionHead(label: 'support'.tr.toUpperCase(), theme: theme),
                  const SizedBox(height: 10),
                  _SupportList(isDark: isDark, cardBg: cardBg, theme: theme),
                  const SizedBox(height: 32),

                  // ── Sign out ──────────────────────────────────────────
                  _SignOutRow(authCtrl: authCtrl, isDark: isDark),
                  const SizedBox(height: 28),

                  // ── Version ───────────────────────────────────────────
                  Center(
                    child: Text(
                      'version'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.hintColor.withValues(alpha: 0.55),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero background — gradient + decorative circles + avatar + name
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeroBg extends StatelessWidget {
  final AuthController authCtrl;
  const _ProfileHeroBg({required this.authCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF14391A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BubblePainter())),
          SafeArea(
            bottom: false,
            child: Obx(() {
              final data = authCtrl.userData.value;
              final name = data?['name'] as String? ?? 'User';
              final email = data?['email'] as String? ?? '';
              final phone = data?['phone'] as String? ?? '';
              final photoUrl = data?['photoUrl'] as String?;
              final initials = ProfileView._initials(name);

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 94,
                          height: 94,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.14),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _InitialsInCircle(initials: initials),
                                  ),
                                )
                              : _InitialsInCircle(initials: initials),
                        ),
                        // Edit badge
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Get.toNamed(AppRoutes.editProfile);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 15,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '+91 $phone',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.52),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InitialsInCircle extends StatelessWidget {
  final String initials;
  const _InitialsInCircle({required this.initials});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: Colors.white.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// Subtle decorative bubbles drawn on the hero background
class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    p.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.08), 120, p);
    p.color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(size.width * 0.06, size.height * 0.78), 90, p);
    p.color = Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 1.15), 140, p);
    p.color = Colors.white.withValues(alpha: 0.025);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * -0.05), 70, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats card — icon + count + label for each stat
// ─────────────────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final int listings;
  final int sold;
  final int bought;
  final bool isDark;
  final Color cardBg;

  const _StatsCard({
    required this.listings,
    required this.sold,
    required this.bought,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.07),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.article_outlined,
            count: listings,
            label: 'stat_listings'.tr,
            color: const Color(0xFF2E7D32),
          ),
          Container(width: 1, height: 52, color: divColor),
          _StatCell(
            icon: Icons.sell_outlined,
            count: sold,
            label: 'stat_sold'.tr,
            color: const Color(0xFFF57C00),
          ),
          Container(width: 1, height: 52, color: divColor),
          _StatCell(
            icon: Icons.shopping_bag_outlined,
            count: bought,
            label: 'stat_bought'.tr,
            color: const Color(0xFF1976D2),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatCell({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats card shimmer — exact same shape/size as _StatsCard
// ─────────────────────────────────────────────────────────────────────────────
class _StatsCardShimmer extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  const _StatsCardShimmer({required this.isDark, required this.cardBg});

  @override
  Widget build(BuildContext context) {
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.07),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _ShimmerStatCell(isDark: isDark),
          Container(width: 1, height: 52, color: divColor),
          _ShimmerStatCell(isDark: isDark),
          Container(width: 1, height: 52, color: divColor),
          _ShimmerStatCell(isDark: isDark),
        ],
      ),
    );
  }
}

class _ShimmerStatCell extends StatelessWidget {
  final bool isDark;
  const _ShimmerStatCell({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KitabShimmer.circle(context: context, size: 22),
          const SizedBox(height: 8),
          KitabShimmer.box(context: context, width: 32, height: 20, radius: 6),
          const SizedBox(height: 5),
          KitabShimmer.box(context: context, width: 48, height: 11, radius: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section head — small uppercase label with a left accent dot
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHead extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionHead({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 13,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.hintColor,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity row — My Listings + Wishlist side by side
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  final int listingCount;
  final bool isDark;
  final Color cardBg;

  const _ActivityRow({
    required this.listingCount,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActivityCard(
            icon: Icons.article_rounded,
            label: 'my_listings'.tr,
            sublabel: 'count_active'.trArgs([listingCount.toString()]),
            color: const Color(0xFF2E7D32),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () {
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.myAds);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActivityCard(
            icon: Icons.favorite_rounded,
            label: 'my_wishlist'.tr,
            sublabel: 'saved_items'.tr,
            color: const Color(0xFFE91E63),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () {
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.wishlist);
            },
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool isDark;
  final Color cardBg;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final hint = Theme.of(context).hintColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded-square icon box
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Text(sublabel, style: TextStyle(fontSize: 12, color: hint)),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'view_all'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 12, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preferences card — dark mode + language with subtitles
// ─────────────────────────────────────────────────────────────────────────────
class _PrefsCard extends StatelessWidget {
  final ThemeController themeCtrl;
  final LanguageController langCtrl;
  final bool isDark;
  final ThemeData theme;
  final Color cardBg;

  const _PrefsCard({
    required this.themeCtrl,
    required this.langCtrl,
    required this.isDark,
    required this.theme,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Dark mode
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                _IconBox(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: const Color(0xFF7C4DFF),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dark_mode'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDark ? 'dark_theme_active'.tr : 'light_theme_active'.tr,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: themeCtrl.isDarkMode(context),
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    themeCtrl.toggleTheme(v);
                  },
                  activeTrackColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          _CardDivider(isDark: isDark),
          // Language
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                const _IconBox(
                  icon: Icons.language_rounded,
                  color: Color(0xFF4DA3FF),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'language'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'app_display_language'.tr,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => _LangSegment(
                    current: langCtrl.currentLang.value,
                    onSelect: (c) {
                      HapticFeedback.selectionClick();
                      langCtrl.changeLanguage(c);
                    },
                    isDark: isDark,
                    primary: theme.colorScheme.primary,
                    hint: theme.hintColor,
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

class _LangSegment extends StatelessWidget {
  final String current;
  final void Function(String) onSelect;
  final bool isDark;
  final Color primary;
  final Color hint;

  const _LangSegment({
    required this.current,
    required this.onSelect,
    required this.isDark,
    required this.primary,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangPill(
            label: 'EN',
            code: 'en',
            selected: current == 'en',
            primary: primary,
            hint: hint,
            onTap: () => onSelect('en'),
          ),
          const SizedBox(width: 3),
          _LangPill(
            label: 'हि',
            code: 'hi',
            selected: current == 'hi',
            primary: primary,
            hint: hint,
            onTap: () => onSelect('hi'),
          ),
        ],
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final Color primary;
  final Color hint;
  final VoidCallback onTap;

  const _LangPill({
    required this.label,
    required this.code,
    required this.selected,
    required this.primary,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : hint,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Support list — Help, Share, Terms, About (with subtitles)
// ─────────────────────────────────────────────────────────────────────────────
class _SupportList extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final ThemeData theme;

  const _SupportList({
    required this.isDark,
    required this.cardBg,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_SItem>[
      _SItem(
        icon: Icons.help_outline_rounded,
        color: const Color(0xFF7C4DFF),
        label: 'help_support'.tr,
        sub: 'faqs_and_contact'.tr,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(AppRoutes.helpSupport);
        },
      ),
      _SItem(
        icon: Icons.share_rounded,
        color: const Color(0xFF4DA3FF),
        label: 'share_app'.tr,
        sub: 'tell_friend'.tr,
        onTap: () {
          HapticFeedback.lightImpact();
          ShareService.shareApp();
        },
      ),
      _SItem(
        icon: Icons.policy_outlined,
        color: const Color(0xFFF57C00),
        label: 'terms_policies'.tr,
        sub: 'privacy_legal'.tr,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(TermsPoliciesView());
        },
      ),
      _SItem(
        icon: Icons.star_rounded,
        color: const Color(0xFFFFB300),
        label: 'rate_us'.tr,
        sub: 'rate_us_subtitle'.tr,
        onTap: () {
          HapticFeedback.lightImpact();
          UpdateService.openPlayStore();
        },
      ),
      _SItem(
        icon: Icons.info_outline_rounded,
        color: const Color(0xFF26C6DA),
        label: 'about_app'.tr,
        sub: 'version_and_credits'.tr,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(AboutView());
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SupportRow(
              item: items[i],
              theme: theme,
              isLast: i == items.length - 1,
            ),
            if (i < items.length - 1) _CardDivider(isDark: isDark),
          ],
        ],
      ),
    );
  }
}

class _SItem {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _SItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.onTap,
  });
}

class _SupportRow extends StatelessWidget {
  final _SItem item;
  final ThemeData theme;
  final bool isLast;

  const _SupportRow({
    required this.item,
    required this.theme,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(20),
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            _IconBox(icon: item.icon, color: item.color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sub,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign out — red bordered row (not a filled button)
// ─────────────────────────────────────────────────────────────────────────────
class _SignOutRow extends StatelessWidget {
  final AuthController authCtrl;
  final bool isDark;

  const _SignOutRow({required this.authCtrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.red.withValues(alpha: 0.07)
          : const Color(0xFFFFF5F5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.mediumImpact();
          authCtrl.showLogoutDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'logout'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'sign_out_subtitle'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.red.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

// Rounded-square icon container (replaces plain circles from old design)
class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _CardDivider extends StatelessWidget {
  final bool isDark;
  const _CardDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 72),
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05),
    );
  }
}

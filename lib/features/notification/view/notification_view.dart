import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing_details/binding/listing_details_binding.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/features/notification/controller/notification_controller.dart';
import 'package:kitab_mandi/features/notification/model/notification_model.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class NotificationView extends StatelessWidget {
  NotificationView({super.key});

  final ctrl = Get.find<NotificationController>();
  final RxBool showUnreadOnly = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'notifications'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white),
        ),
        actions: [
          Obx(() {
            final hasUnread = ctrl.notifications.any((n) => !n.isRead);
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton(
              onPressed: ctrl.markAllRead,
              child: Text(
                'mark_all_read'.tr,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.white24),
        ),
      ),
      body: Obx(() {
        // ── Loading skeleton ─────────────────────────────────────────────
        if (ctrl.isLoading.value) {
          return _LoadingSkeleton(isDark: isDark);
        }

        final all = ctrl.notifications;
        final visible = showUnreadOnly.value
            ? all.where((n) => !n.isRead).toList()
            : all.toList();

        return Column(
          children: [
            // ── Filter pills ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Obx(() => Row(
                    children: [
                      _FilterPill(
                        label: 'all_notifs'.tr,
                        selected: !showUnreadOnly.value,
                        count: all.length,
                        onTap: () => showUnreadOnly.value = false,
                        theme: theme,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _FilterPill(
                        label: 'unread'.tr,
                        selected: showUnreadOnly.value,
                        count: ctrl.unreadCount,
                        onTap: () => showUnreadOnly.value = true,
                        theme: theme,
                        isDark: isDark,
                      ),
                    ],
                  )),
            ),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: visible.isEmpty
                  ? _EmptyState(theme: theme, isDark: isDark)
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _buildSections(visible).length,
                      itemBuilder: (_, i) {
                        final item = _buildSections(visible)[i];
                        if (item is String) {
                          return _SectionLabel(label: item, theme: theme);
                        }
                        final notif = item as NotificationModel;
                        return _NotifCard(
                          notif: notif,
                          onTap: () {
                            ctrl.markRead(notif.id);
                            _navigateFromNotif(notif);
                          },
                          onDismiss: () => ctrl.remove(notif.id),
                          theme: theme,
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  // Navigate to the relevant screen when a notification card is tapped.
  void _navigateFromNotif(NotificationModel notif) {
    final payload = notif.payload ?? {};
    switch (notif.type) {
      case NotifType.chat:
        final chatId = payload['chat_id'] as String?;
        if (chatId != null && chatId.isNotEmpty) {
          Get.toNamed(AppRoutes.chatRoom, arguments: {
            'chatId': chatId,
            'userName': payload['sender_name'] ?? '',
            'listingTitle': payload['listing_title'] ?? '',
            'listingImage': '',
            'otherUserId': payload['sender_id'] ?? '',
          });
        } else {
          Get.toNamed(AppRoutes.chatView);
        }
        break;
      case NotifType.listing:
      case NotifType.offer:
        final listingId = payload['listing_id'] as String?;
        if (listingId != null && listingId.isNotEmpty) {
          _openListing(listingId);
        }
        break;
      case NotifType.system:
        break;
    }
  }

  // Fetches the listing from Firestore then pushes ListingDetailsView.
  Future<void> _openListing(String listingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .get();
      if (!doc.exists) return;
      final listing = ListingModel.fromMap(doc.data()!, doc.id);
      Get.to(
        () => ListingDetailsView(listing: listing, docId: listingId),
        binding: ListingDetailsBinding(),
      );
    } catch (e) {
      debugPrint('[NotifView] _openListing error: $e');
    }
  }

  // Groups notifications into Today / Yesterday / Earlier sections
  List<dynamic> _buildSections(List<NotificationModel> list) {
    final now = DateTime.now();
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final earlier = <NotificationModel>[];

    for (final n in list) {
      final diff = now.difference(n.createdAt).inHours;
      if (diff < 24) {
        today.add(n);
      } else if (diff < 48) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }

    final result = <dynamic>[];
    if (today.isNotEmpty) {
      result.add('today');
      result.addAll(today);
    }
    if (yesterday.isNotEmpty) {
      result.add('yesterday');
      result.addAll(yesterday);
    }
    if (earlier.isNotEmpty) {
      result.add('earlier');
      result.addAll(earlier);
    }
    return result;
  }
}

// ── Filter pill ───────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final int count;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.count,
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : isDark
                  ? const Color(0xFF1E2128)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : theme.hintColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : theme.colorScheme.primary,
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

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    final text = label == 'today'
        ? 'today_label'.tr
        : label == 'yesterday'
            ? 'yesterday_label'.tr
            : 'earlier_label'.tr;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme.hintColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final ThemeData theme;
  final bool isDark;

  const _NotifCard({
    required this.notif,
    required this.onTap,
    required this.onDismiss,
    required this.theme,
    required this.isDark,
  });

  Color _typeColor() {
    switch (notif.type) {
      case NotifType.chat:    return AppColors.primary;
      case NotifType.listing: return AppColors.secondary;
      case NotifType.offer:   return const Color(0xFF7C3AED);
      case NotifType.system:  return const Color(0xFF1565C0);
    }
  }

  IconData _typeIcon() {
    switch (notif.type) {
      case NotifType.chat:    return Icons.chat_bubble_rounded;
      case NotifType.listing: return Icons.local_offer_rounded;
      case NotifType.offer:   return Icons.sell_rounded;
      case NotifType.system:  return Icons.notifications_rounded;
    }
  }

  String _typeLabel() {
    switch (notif.type) {
      case NotifType.chat:    return 'notif_type_chat'.tr;
      case NotifType.listing: return 'notif_type_listing'.tr;
      case NotifType.offer:   return 'notif_type_offer'.tr;
      case NotifType.system:  return 'notif_type_system'.tr;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(notif.createdAt);
    if (diff.inMinutes < 1) return 'just_now'.tr;
    if (diff.inMinutes < 60) return 'minutes_ago'.trParams({'0': diff.inMinutes.toString()});
    if (diff.inHours < 24) return 'hours_ago'.trParams({'0': diff.inHours.toString()});
    if (diff.inDays == 1) return 'yesterday_label'.tr;
    return 'days_ago'.trParams({'0': diff.inDays.toString()});
  }

  @override
  Widget build(BuildContext context) {
    final tc = _typeColor();
    final unread = !notif.isRead;
    final cardBg = unread
        ? (isDark
            ? tc.withValues(alpha: 0.07)
            : tc.withValues(alpha: 0.04))
        : (isDark ? const Color(0xFF1A1D23) : Colors.white);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread
                  ? tc.withValues(alpha: 0.18)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unread accent bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 4,
                  decoration: BoxDecoration(
                    color: unread ? tc : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Icon
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tc.withValues(alpha: 0.12),
                    ),
                    child: Icon(_typeIcon(), size: 20, color: tc),
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: unread
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: unread
                                      ? theme.textTheme.bodyLarge?.color
                                      : theme.hintColor,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Read / Unread badge
                            if (unread)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: tc,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'new_badge'.tr,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'read_badge'.tr,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: theme.hintColor.withValues(alpha: 0.5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Body
                        Text(
                          notif.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: theme.hintColor,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Type chip + time
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tc.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _typeLabel(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: tc,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _timeAgo(),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  final bool isDark;
  const _LoadingSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 86,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: base,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: base,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 12, width: 160, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
                    Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
                    Container(height: 10, width: 100, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;

  const _EmptyState({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Icon(Icons.notifications_off_outlined,
                size: 34, color: theme.hintColor),
          ),
          const SizedBox(height: 18),
          Text(
            'no_notifications'.tr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'notifications_appear_here'.tr,
            style: TextStyle(fontSize: 13, color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

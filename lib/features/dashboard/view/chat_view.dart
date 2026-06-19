import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/notification_bell.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';
import 'package:shimmer/shimmer.dart';

class ChatView extends StatelessWidget {
  final controller = Get.find<ChatController>();
  ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const appBarBg = AppColors.primary;
    final indicatorColor = isDark ? AppColors.primaryLight : Colors.white;
    final labelColor = Colors.white;
    final unselectedColor = Colors.white.withValues(alpha: 0.6);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F1115)
            : const Color(0xFFF7F8FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarBg,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'chats'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          actions: const [NotificationBell(), SizedBox(width: 4)],
          bottom: TabBar(
            tabAlignment: TabAlignment.fill,
            indicatorColor: indicatorColor,
            indicatorWeight: 3,
            labelColor: labelColor,
            unselectedLabelColor: unselectedColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 16),
                    const SizedBox(width: 7),
                    Text('buying'.tr),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 16),
                    const SizedBox(width: 7),
                    Text('selling'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BuyingProductsView(controller: controller),
            SellingProductsView(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ── Buying tab ────────────────────────────────────────────────────────────────
class BuyingProductsView extends StatelessWidget {
  final ChatController controller;
  const BuyingProductsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getBuyingProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ChatListShimmer();
        }
        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'something_went_wrong'.tr,
            subtitle: 'pull_down_refresh'.tr,
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'no_conversations_yet'.tr,
            subtitle: 'browse_listings_start_chat'.tr,
          );
        }

        // One chat per product (buyer ↔ seller)
        final Map<String, Map<String, dynamic>> seen = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = data['listingId'] as String?;
          if (id != null && !seen.containsKey(id)) seen[id] = data;
        }
        final chats = seen.values.toList()
          ..sort((a, b) {
            final ta = a['lastMessageTime'];
            final tb = b['lastMessageTime'];
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return (tb as Timestamp).compareTo(ta as Timestamp);
          });

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final sellerId = chat['sellerId'] as String? ?? '';
            final currentId = controller.currentUserId ?? '';
            final rawUnread = chat['unreadCount'] as int? ?? 0;
            final isMe = chat['lastSenderId'] == currentId;
            final unread = isMe ? 0 : rawUnread;

            return FutureBuilder<Map<String, dynamic>?>(
              future: controller.getUserCached(sellerId),
              builder: (context, snap) {
                if (!snap.hasData) return const _ChatTileShimmer();
                final user = snap.data!;
                final name = user['name'] as String? ?? 'seller'.tr;
                final avatar = (user['photoUrl'] as String?) ?? '';

                return _ConversationTile(
                  name: name,
                  avatar: avatar,
                  productTitle: chat['listingTitle'] as String? ?? '',
                  lastMessage:
                      chat['lastMessage'] as String? ?? 'tap_to_chat'.tr,
                  time: chat['lastMessageTime'],
                  isMe: isMe,
                  isSeen: chat['isSeen'] as bool? ?? true,
                  unreadCount: unread,
                  onTap: () => Get.toNamed(
                    AppRoutes.chatRoom,
                    arguments: {
                      'chatId': chat['chatId'],
                      'listingTitle': chat['listingTitle'],
                      'listingImage': chat['listingImage'],
                      'userName': name,
                      'otherUserId': sellerId,
                      'listingId': chat['listingId'] ?? '',
                      'sellerUid': chat['sellerId'] ?? '',
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── Selling tab ───────────────────────────────────────────────────────────────
class SellingProductsView extends StatelessWidget {
  final ChatController controller;
  const SellingProductsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getSellingProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _CardListShimmer();
        }
        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'something_went_wrong'.tr,
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyState(
            icon: Icons.storefront_outlined,
            title: 'no_buyers_yet'.tr,
            subtitle: 'post_listing_for_messages'.tr,
          );
        }

        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = data['listingId'] as String?;
          if (id == null) continue;
          grouped.putIfAbsent(id, () => []);
          grouped[id]!.add(data);
        }

        final entries = grouped.entries.toList()
          ..sort((a, b) {
            final ta = a.value.first['lastMessageTime'];
            final tb = b.value.first['lastMessageTime'];
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return (tb as Timestamp).compareTo(ta as Timestamp);
          });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final chats = entries[index].value;
            final item = chats.first;
            final buyerCount = chats.length;
            return _ProductCard(
              item: item,
              buyerCount: buyerCount,
              onTap: () => Get.to(
                () => UsersListView(
                  listingId: item['listingId'] as String,
                  title: item['listingTitle'] as String? ?? '',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Conversation tile (WhatsApp-style) ───────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String productTitle;
  final String lastMessage;
  final dynamic time;
  final bool isMe;
  final bool isSeen;
  final int unreadCount;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    required this.avatar,
    required this.productTitle,
    required this.lastMessage,
    required this.time,
    required this.isMe,
    required this.isSeen,
    required this.unreadCount,
    required this.onTap,
  });

  String _fmt(dynamic ts) {
    if (ts == null) return '';
    try {
      final d = (ts as Timestamp).toDate();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inDays == 0) {
        final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
        final m = d.minute.toString().padLeft(2, '0');
        return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
      }
      if (diff.inDays == 1) return 'yesterday'.tr;
      if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[d.weekday - 1];
      }
      return '${d.day}/${d.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasUnread = unreadCount > 0;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.06);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryDark.withValues(alpha: 0.12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: avatar.isNotEmpty
                          ? AppCachedImageNetwork(
                              imageUrl: avatar,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person_rounded,
                              size: 28,
                              color: AppColors.primaryLight,
                            ),
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF0F1115)
                                  : const Color(0xFFF7F8FA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 13),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _fmt(time),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: hasUnread
                                  ? AppColors.primary
                                  : theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Product context chip
                      if (productTitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  productTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Last message + unread badge
                      Row(
                        children: [
                          if (isMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.done_all_rounded,
                                size: 15,
                                color: isSeen
                                    ? const Color(0xFF53BDEB)
                                    : theme.hintColor,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: hasUnread
                                    ? (isDark ? Colors.white70 : Colors.black87)
                                    : theme.hintColor,
                              ),
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              constraints: const BoxConstraints(minWidth: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, indent: 83, color: dividerColor),
        ],
      ),
    );
  }
}

// ── Product card (selling tab) ─────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int buyerCount;
  final VoidCallback onTap;

  const _ProductCard({
    required this.item,
    required this.buyerCount,
    required this.onTap,
  });

  String _fmt(dynamic ts) {
    if (ts == null) return '';
    try {
      final d = (ts as Timestamp).toDate();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inDays == 0) {
        final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
        final m = d.minute.toString().padLeft(2, '0');
        return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
      }
      if (diff.inDays == 1) return 'yesterday'.tr;
      if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[d.weekday - 1];
      }
      return '${d.day}/${d.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppCachedImageNetwork(
                  height: 72,
                  width: 72,
                  imageUrl: item['listingImage'] as String? ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['listingTitle'] as String? ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.3,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _fmt(item['lastMessageTime']),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['lastMessage'] as String? ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: theme.hintColor),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (buyerCount == 1
                                    ? 'buyer_interested_one'
                                    : 'buyer_interested_many')
                                .trParams({'0': buyerCount.toString()}),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: theme.hintColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Users list (buyers for a specific listing) ────────────────────────────────
class UsersListView extends StatelessWidget {
  final String listingId;
  final String title;

  const UsersListView({
    super.key,
    required this.listingId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const appBarBg = AppColors.primary;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1115)
          : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getUsersForListing(listingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ChatListShimmer();
          }
          if (snapshot.hasError) {
            return _EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'error_loading_chats'.tr,
            );
          }

          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) {
            return _EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'no_conversations_yet'.tr,
              subtitle: 'buyers_appear_message'.tr,
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final chat = users[index].data() as Map<String, dynamic>;
              final currentId = controller.currentUserId!;
              final isBuyer = chat['buyerId'] == currentId;
              final otherUserId = isBuyer
                  ? chat['sellerId'] as String
                  : chat['buyerId'] as String;
              final isMe = chat['lastSenderId'] == currentId;
              final rawUnread = chat['unreadCount'] as int? ?? 0;
              final unread = isMe ? 0 : rawUnread;

              return FutureBuilder<Map<String, dynamic>?>(
                future: controller.getUserCached(otherUserId),
                builder: (context, snap) {
                  if (!snap.hasData) return const _ChatTileShimmer();
                  final user = snap.data!;
                  final name = user['name'] as String? ?? 'User';
                  final image = (user['photoUrl'] as String?) ?? '';

                  return _ConversationTile(
                    name: name,
                    avatar: image,
                    productTitle: '',
                    lastMessage: chat['lastMessage'] as String? ?? '',
                    time: chat['lastMessageTime'],
                    isMe: isMe,
                    isSeen: chat['isSeen'] as bool? ?? true,
                    unreadCount: unread,
                    onTap: () => Get.toNamed(
                      AppRoutes.chatRoom,
                      arguments: {
                        'chatId': chat['chatId'],
                        'listingTitle': chat['listingTitle'],
                        'listingImage': chat['listingImage'],
                        'userName': name,
                        'otherUserId': otherUserId,
                        'listingId': chat['listingId'] ?? '',
                        'sellerUid': chat['sellerId'] ?? '',
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ── Shimmers ──────────────────────────────────────────────────────────────────
class _ChatListShimmer extends StatelessWidget {
  const _ChatListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 8,
      itemBuilder: (_, index) => const _ChatTileShimmer(),
    );
  }
}

class _ChatTileShimmer extends StatelessWidget {
  const _ChatTileShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252830) : Colors.grey.shade200;
    final hi = isDark ? const Color(0xFF30343E) : Colors.grey.shade50;
    final fill = isDark ? const Color(0xFF1E2128) : Colors.white;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 13,
                        width: 120,
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 11,
                        width: 40,
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 11,
                    width: 200,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardListShimmer extends StatelessWidget {
  const _CardListShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252830) : Colors.grey.shade200;
    final hi = isDark ? const Color(0xFF30343E) : Colors.grey.shade50;
    final fill = isDark ? const Color(0xFF1E2128) : Colors.white;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      itemCount: 5,
      itemBuilder: (_, index) => Shimmer.fromColors(
        baseColor: base,
        highlightColor: hi,
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _EmptyState({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2430)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 42,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 7),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.hintColor,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

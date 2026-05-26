import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';
import 'package:shimmer/shimmer.dart';

class ChatView extends StatelessWidget {
  final controller = Get.put(ChatController());

  ChatView({super.key});

  Color _bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF121212)
      : Colors.white;

  Color _appBarBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg(context),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _appBarBg(context),
          title: const Text(
            "Chats",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            indicatorWeight: 3,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: "Buying"),
              Tab(text: "Selling"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [BuyingProductsView(), SellingProductsView()],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// BUYING VIEW
///////////////////////////////////////////////////////////////
class BuyingProductsView extends StatelessWidget {
  const BuyingProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return StreamBuilder<QuerySnapshot>(
      stream: controller.getBuyingProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ShimmerList();
        }

        if (snapshot.hasError) {
          return const _EmptyState(
            icon: Icons.error_outline,
            text: "Something went wrong",
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const _EmptyState(
            icon: Icons.shopping_bag_outlined,
            text: "No products yet",
          );
        }

        final Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = data['listingId'];
          if (id == null) continue;
          grouped.putIfAbsent(id, () => []);
          grouped[id]!.add(data);
        }

        final products = grouped.values.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index].first;
            final count = products[index].length;

            return _PremiumCard(
              item: item,
              count: count,
              label: "$count Lead${count == 1 ? '' : 's'}",
            );
          },
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////
/// SELLING VIEW
///////////////////////////////////////////////////////////////
class SellingProductsView extends StatelessWidget {
  const SellingProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return StreamBuilder<QuerySnapshot>(
      stream: controller.getSellingProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ShimmerList();
        }

        if (snapshot.hasError) {
          return const _EmptyState(
            icon: Icons.error_outline,
            text: "Something went wrong",
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const _EmptyState(
            icon: Icons.inventory_2_outlined,
            text: "No buyers yet",
          );
        }

        final Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = data['listingId'];
          if (id == null) continue;
          grouped.putIfAbsent(id, () => []);
          grouped[id]!.add(data);
        }

        final products = grouped.values.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index].first;
            final count = products[index].length;

            return _PremiumCard(
              item: item,
              count: count,
              label: "$count Interested",
            );
          },
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////
/// PREMIUM CARD
///////////////////////////////////////////////////////////////
class _PremiumCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int count;
  final String label;

  const _PremiumCard({
    required this.item,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Get.to(
          () => UsersListView(
            listingId: item['listingId'],
            title: item['listingTitle'] ?? '',
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppCachedImageNetwork(
                  height: 80,
                  width: 80,
                  borderRadius: BorderRadius.circular(12),
                  imageUrl: item['listingImage'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['listingTitle'] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹${item['price'] ?? "0"}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// SHIMMER LIST
///////////////////////////////////////////////////////////////
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: isDark ? const Color(0xFF1E2430) : Colors.grey.shade300,
            highlightColor: isDark
                ? const Color(0xFF2A3140)
                : Colors.grey.shade100,
            child: Container(
              height: 104,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF171B22) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////
/// EMPTY STATE
///////////////////////////////////////////////////////////////
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// USERS LIST VIEW
///////////////////////////////////////////////////////////////
class UsersListView extends StatelessWidget {
  final String listingId;
  final String title;

  const UsersListView({
    super.key,
    required this.listingId,
    required this.title,
  });

  Color _appBarBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: _appBarBg(context),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getUsersForListing(listingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ChatShimmerList();
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.error_outline,
              text: "Error loading chats",
            );
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const _EmptyState(
              icon: Icons.chat_bubble_outline,
              text: "No conversations yet",
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 78,
              color: theme.dividerColor.withOpacity(0.15),
            ),
            itemBuilder: (context, index) {
              final chat = users[index].data() as Map<String, dynamic>;
              final currentUserId = controller.currentUser!.uid;

              final isBuyer = chat['buyerId'] == currentUserId;
              final otherUserId = isBuyer ? chat['sellerId'] : chat['buyerId'];

              final lastMessage = chat['lastMessage'] ?? "Start conversation";
              final time = chat['lastMessageTime'];
              final isMe = chat['lastSenderId'] == currentUserId;
              final isSeen = chat['isSeen'] ?? false;
              final unreadCount = chat['unreadCount'] ?? 0;

              return FutureBuilder<Map<String, dynamic>?>(
                future: controller.getUserCached(otherUserId),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const _ChatTileShimmer();
                  }

                  final user = userSnap.data!;
                  final name = user['name'] ?? "User";
                  final image = user['image'] ?? "";

                  return _ChatTile(
                    name: name,
                    image: image,
                    lastMessage: lastMessage,
                    time: time,
                    isMe: isMe,
                    isSeen: isSeen,
                    unreadCount: unreadCount,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.chatRoom,
                        arguments: {
                          "chatId": chat['chatId'],
                          "listingTitle": chat['listingTitle'],
                          "listingImage": chat['listingImage'],
                          "userName": name,
                        },
                      );
                    },
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

///////////////////////////////////////////////////////////////
/// CHAT TILE (extracted widget for cleanliness)
///////////////////////////////////////////////////////////////
class _ChatTile extends StatelessWidget {
  final String name;
  final String image;
  final String lastMessage;
  final dynamic time;
  final bool isMe;
  final bool isSeen;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatTile({
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.time,
    required this.isMe,
    required this.isSeen,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = !isMe && unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppColors.primaryDark.withOpacity(0.15),
              radius: 26,
              backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
              child: image.isEmpty
                  ? Icon(Icons.person, color: AppColors.primaryDark, size: 24)
                  : null,
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(time, context),
                        style: TextStyle(
                          color: hasUnread
                              ? theme.colorScheme.primary
                              : theme.hintColor,
                          fontSize: 11,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (isMe) ...[
                        Icon(
                          Icons.done_all,
                          size: 15,
                          color: isSeen ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread
                                ? theme.textTheme.bodyMedium?.color
                                : theme.hintColor,
                            fontSize: 13,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount > 99 ? "99+" : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
    );
  }

  String _formatTime(dynamic timestamp, BuildContext context) {
    if (timestamp == null) return "";
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        return TimeOfDay.fromDateTime(date).format(context);
      } else if (diff.inDays == 1) {
        return "Yesterday";
      } else if (diff.inDays < 7) {
        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        return days[date.weekday - 1];
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (_) {
      return "";
    }
  }
}

///////////////////////////////////////////////////////////////
/// CHAT SHIMMER LIST
///////////////////////////////////////////////////////////////
class _ChatShimmerList extends StatelessWidget {
  const _ChatShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (_, __) => const _ChatTileShimmer(),
    );
  }
}

///////////////////////////////////////////////////////////////
/// SINGLE CHAT TILE SHIMMER
///////////////////////////////////////////////////////////////
class _ChatTileShimmer extends StatelessWidget {
  const _ChatTileShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2430) : Colors.grey.shade200,
      highlightColor: isDark ? const Color(0xFF2A3140) : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF2A3140) : Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 13,
                    width: 130,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A3140) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 11,
                    width: 200,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A3140) : Colors.white,
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

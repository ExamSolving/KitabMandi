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
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
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
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index].first;
            final count = products[index].length;

            return _PremiumCard(
              item: item,
              count: count,
              label: "$count Leads",
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
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index].first;
            final count = products[index].length;

            return _PremiumCard(
              item: item,
              count: count,
              label: "$count interested",
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

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Get.to(
          () => UsersListView(
            listingId: item['listingId'],
            title: item['listingTitle'],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, top: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// IMAGE WITH SHIMMER
            AppCachedImageNetwork(
              height: 100,
              width: 100,
              borderRadius: BorderRadius.circular(10),
              imageUrl: item['listingImage'],
              fit: BoxFit.cover, //  IMPORTANT (not fill)
            ),
            const SizedBox(width: 12),

            /// DETAILS
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
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹ ${item['price'] ?? "0"}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// SHIMMER IMAGE
///////////////////////////////////////////////////////////////
// class _NetworkImage extends StatelessWidget {
//   final String? url;

//   const _NetworkImage(this.url);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(14),
//       child: SizedBox(
//         height: 100,
//         width: 100,
//         child: AppCachedImageNetwork(
//           imageUrl: url ?? "",
//           fit: BoxFit.cover, // ✅ IMPORTANT (not fill)
//         ),
//       ),
//     );
//   }
// }

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
          padding: const EdgeInsets.only(bottom: 14),

          child: Shimmer.fromColors(
            baseColor: isDark ? const Color(0xFF1E2430) : Colors.grey.shade300,

            highlightColor: isDark
                ? const Color(0xFF2A3140)
                : Colors.grey.shade100,

            child: Container(
              height: 100,

              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF171B22) : Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),

                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.25)
                        : Colors.black.withOpacity(0.04),

                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
          Icon(icon, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

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

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: _appBarBg(context)),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getUsersForListing(listingId),
        builder: (context, snapshot) {
          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ChatShimmerList();
          }

          /// ERROR
          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.error_outline,
              text: "Error loading chats",
            );
          }

          final users = snapshot.data?.docs ?? [];

          /// EMPTY
          if (users.isEmpty) {
            return const _EmptyState(
              icon: Icons.chat_bubble_outline,
              text: "No conversations yet",
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final chat = users[index].data() as Map<String, dynamic>;
              final currentUserId = controller.currentUser!.uid;

              final isBuyer = chat['buyerId'] == currentUserId;
              final otherUserId = isBuyer ? chat['sellerId'] : chat['buyerId'];

              final lastMessage = chat['lastMessage'] ?? "Start conversation";
              final time = chat['lastMessageTime'];

              final isMe = chat['lastSenderId'] == currentUserId;
              final isSeen = chat['isSeen'] ?? false;

              return FutureBuilder<Map<String, dynamic>?>(
                future: controller.getUserCached(otherUserId),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const _ChatTileShimmer();
                  }

                  final user = userSnap.data!;
                  final name = user['name'] ?? "User";
                  final image = user['image'] ?? "";

                  return InkWell(
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          /// AVATAR
                          CircleAvatar(
                            backgroundColor: AppColors.primaryDark,
                            radius: 26,
                            backgroundImage: image.isNotEmpty
                                ? NetworkImage(image)
                                : null,
                            child: image.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),

                          const SizedBox(width: 12),

                          /// CHAT INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// NAME + TIME
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      _formatTime(time),
                                      style: TextStyle(
                                        color: theme.hintColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// LAST MESSAGE + UNREAD
                                Row(
                                  children: [
                                    if (isMe) ...[
                                      buildTick(isMe, isSeen),
                                      const SizedBox(width: 4),
                                    ],

                                    Expanded(
                                      child: Text(
                                        lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: theme.hintColor,
                                        ),
                                      ),
                                    ),

                                    if ((chat['unreadCount'] ?? 0) > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          chat['unreadCount'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
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
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget buildTick(bool isMe, bool isSeen) {
    if (!isMe) return const SizedBox();

    return Icon(
      Icons.done_all,
      size: 16,
      color: isSeen ? Colors.blue : Colors.grey,
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return TimeOfDay.fromDateTime(date).format(Get.context!);
    } else if (now.difference(date).inDays == 1) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
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
      itemCount: 6,
      padding: const EdgeInsets.all(12),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1E2430) : Colors.grey.shade300,

        highlightColor: isDark ? const Color(0xFF2A3140) : Colors.grey.shade100,

        child: Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171B22) : Colors.white,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),

            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.04),

                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              /// Avatar shimmer
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF2A3140) : Colors.white,
                ),
              ),

              const SizedBox(width: 14),

              /// Text shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      height: 12,
                      width: 120,

                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A3140) : Colors.white,

                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 10,
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
      ),
    );
  }
}

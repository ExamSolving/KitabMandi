import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';

class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  late final Map<String, dynamic> _args;
  late final String _chatId;

  bool _isSending = false;
  bool _isMarkingInProgress = false;

  // Debounce timer to batch seen-marking calls
  Timer? _seenDebounce;

  @override
  void initState() {
    super.initState();
    _args = Get.arguments as Map<String, dynamic>;
    _chatId = _args['chatId'] as String;

    // Reset unread count immediately on open
    _resetUnreadCount();

    // Scroll to bottom when keyboard opens
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom(animated: true);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _seenDebounce?.cancel();
    super.dispose();
  }

  Future<void> _resetUnreadCount() async {
    try {
      await _firestore.collection('chats').doc(_chatId).update({
        'unreadCount': 0,
      });
    } catch (_) {}
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(maxExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final batch = _firestore.batch();

      final msgRef = _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc();

      batch.set(msgRef, {
        "senderId": _currentUser!.uid,
        "message": text,
        "timestamp": FieldValue.serverTimestamp(),
        "isSeen": false,
      });

      final chatRef = _firestore.collection('chats').doc(_chatId);
      batch.update(chatRef, {
        "lastMessage": text,
        "lastSenderId": _currentUser.uid,
        "isSeen": false,
        "lastMessageTime": FieldValue.serverTimestamp(),
        "unreadCount": FieldValue.increment(1),
      });

      await batch.commit();

      // Scroll to bottom after send
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: true);
      });
    } catch (e) {
      // Restore text on failure
      _messageController.text = text;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Debounced mark-as-seen to avoid repeated Firestore writes
  void _scheduleMarkAsSeen(List<QueryDocumentSnapshot> messages) {
    _seenDebounce?.cancel();
    _seenDebounce = Timer(const Duration(milliseconds: 500), () {
      _markMessagesAsSeen(messages);
    });
  }

  Future<void> _markMessagesAsSeen(List<QueryDocumentSnapshot> messages) async {
    if (_isMarkingInProgress) return;
    _isMarkingInProgress = true;

    try {
      final unseenFromOther = messages.where((msg) {
        final data = msg.data() as Map<String, dynamic>;
        return data['senderId'] != _currentUser!.uid &&
            (data['isSeen'] == false);
      }).toList();

      if (unseenFromOther.isEmpty) return;

      final batch = _firestore.batch();

      for (final msg in unseenFromOther) {
        batch.update(
          _firestore
              .collection('chats')
              .doc(_chatId)
              .collection('messages')
              .doc(msg.id),
          {"isSeen": true},
        );
      }

      batch.update(_firestore.collection('chats').doc(_chatId), {
        "isSeen": true,
        "unreadCount": 0,
      });

      await batch.commit();
    } catch (_) {
    } finally {
      _isMarkingInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF2F4F8);
    final appBarBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(appBarBg, isDark),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(isDark, theme)),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color bg, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: bg,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryDark.withOpacity(0.15),
            child: Icon(Icons.person, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _args['userName'] ?? "Chat",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((_args['listingTitle'] ?? "").isNotEmpty)
                  Text(
                    _args['listingTitle'],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark, ThemeData theme) {
    final otherMsgColor = isDark
        ? const Color(0xFF1F2937)
        : Colors.grey.shade200;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter out messages with null timestamp (optimistic local writes)
        final docs = snapshot.data!.docs;
        final messages = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['timestamp'] != null;
        }).toList();

        if (messages.isEmpty) {
          return _buildEmptyConversation(isDark);
        }

        // Mark unseen messages (debounced)
        _scheduleMarkAsSeen(messages);

        // Scroll to bottom on new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final pos = _scrollController.position;
            // Auto-scroll only if near bottom (within 200px)
            if (pos.maxScrollExtent - pos.pixels < 200) {
              _scrollToBottom(animated: true);
            }
          }
        });

        final grouped = _groupMessagesByDate(messages);

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped[index];
            final dateLabel = entry['date'] as String;
            final msgs = entry['messages'] as List<QueryDocumentSnapshot>;

            return Column(
              children: [
                _DateHeader(label: dateLabel, isDark: isDark),
                ...msgs.map((msg) {
                  final data = msg.data() as Map<String, dynamic>;
                  final isMe = data['senderId'] == _currentUser!.uid;
                  return _MessageBubble(
                    msg: data,
                    isMe: isMe,
                    otherColor: otherMsgColor,
                    theme: theme,
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyConversation(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand_rounded,
            size: 48,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            "Say hello!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D23) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F1115)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(isSending: _isSending, onTap: _sendMessage),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupMessagesByDate(
    List<QueryDocumentSnapshot> messages,
  ) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    final List<String> order = [];

    for (var msg in messages) {
      final ts = msg['timestamp'];
      if (ts == null) continue;

      final date = (ts as Timestamp).toDate();
      final key = _getDateLabel(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
        order.add(key);
      }
      grouped[key]!.add(msg);
    }

    return order
        .map((key) => {"date": key, "messages": grouped[key]!})
        .toList();
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff <= 6) {
      const days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ];
      return days[date.weekday - 1];
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}

///////////////////////////////////////////////////////////////
/// SEND BUTTON
///////////////////////////////////////////////////////////////
class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onTap;

  const _SendButton({required this.isSending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSending ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isSending
              ? AppColors.primaryDark.withOpacity(0.6)
              : AppColors.primaryDark,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isSending
            ? const Padding(
                padding: EdgeInsets.all(13),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// DATE HEADER
///////////////////////////////////////////////////////////////
class _DateHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// MESSAGE BUBBLE
///////////////////////////////////////////////////////////////
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final Color otherColor;
  final ThemeData theme;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.otherColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSeen = msg['isSeen'] ?? false;
    final time = msg['timestamp'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : otherColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg['message'] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(time, context),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white60 : Colors.grey.shade500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: isSeen ? Colors.blue.shade200 : Colors.white54,
                  ),
                ],
              ],
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
      return TimeOfDay.fromDateTime(date).format(context);
    } catch (_) {
      return "";
    }
  }
}

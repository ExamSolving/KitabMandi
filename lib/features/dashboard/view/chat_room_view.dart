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
  final currentUser = FirebaseAuth.instance.currentUser;

  final args = Get.arguments;
  final TextEditingController messageController = TextEditingController();

  bool _isMarking = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();

    /// ⏱ Controlled loader (prevents flicker)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    });
  }

  Color _appBarBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final chatId = args['chatId'];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F7FB);

    final otherMsgColor = isDark
        ? const Color(0xFF1F2937)
        : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _appBarBg(context),
        title: Text(
          args['userName'] ?? "Chat",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          /// ================= MESSAGE LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(includeMetadataChanges: true),
              builder: (context, snapshot) {
                ///  ERROR
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                ///  INITIAL LOADER (ONLY SHORT TIME)
                if (_isInitialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                ///  NO DATA
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                ///  FILTER VALID MESSAGES
                final messages = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['timestamp'] != null;
                }).toList();

                /// EMPTY STATE
                if (messages.isEmpty) {
                  return const Center(child: Text("Start conversation 👋"));
                }

                /// MARK AS SEEN
                Future.microtask(() {
                  _markMessagesAsSeen(messages, chatId);
                });

                final grouped = _groupMessagesByDate(messages);

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView.builder(
                    key: ValueKey(messages.length),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final entry = grouped[index];
                      final dateLabel = entry['date'];
                      final msgs = entry['messages'];

                      return Column(
                        children: [
                          _dateHeader(dateLabel, isDark),
                          ...msgs.map((msg) {
                            final data = msg.data() as Map<String, dynamic>;
                            final isMe = data['senderId'] == currentUser!.uid;

                            return _messageBubble(
                              msg: data,
                              isMe: isMe,
                              messageId: msg.id,
                              chatId: chatId,
                              otherColor: otherMsgColor,
                              theme: theme,
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),

          /// ================= INPUT =================
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1D23)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      if (messageController.text.trim().isEmpty) return;

                      final text = messageController.text.trim();

                      await _firestore
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                            "senderId": currentUser!.uid,
                            "message": text,
                            "timestamp": FieldValue.serverTimestamp(),
                            "isSeen": false,
                          });

                      await _firestore.collection('chats').doc(chatId).update({
                        "lastMessage": text,
                        "lastSenderId": currentUser?.uid,
                        "isSeen": false,
                        "lastMessageTime": FieldValue.serverTimestamp(),
                      });

                      messageController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
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

  /// ================= MARK AS SEEN =================
  void _markMessagesAsSeen(
    List<QueryDocumentSnapshot> messages,
    String chatId,
  ) async {
    if (_isMarking) return;

    _isMarking = true;

    bool shouldMarkChatSeen = false;

    for (var msg in messages) {
      final data = msg.data() as Map<String, dynamic>;

      /// If message is from OTHER user → I am receiver
      if (data['senderId'] != currentUser!.uid && data['isSeen'] == false) {
        shouldMarkChatSeen = true;

        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(msg.id)
            .update({"isSeen": true});
      }
    }

    ///  ONLY update chat if I am RECEIVER
    if (shouldMarkChatSeen) {
      await _firestore.collection("chats").doc(chatId).update({"isSeen": true});
    }

    _isMarking = false;
  }

  /// ================= GROUP BY DATE =================
  List<Map<String, dynamic>> _groupMessagesByDate(
    List<QueryDocumentSnapshot> messages,
  ) {
    messages.sort((a, b) {
      final aTime = (a['timestamp'] as Timestamp?)?.toDate();
      final bTime = (b['timestamp'] as Timestamp?)?.toDate();
      if (aTime == null || bTime == null) return 0;
      return aTime.compareTo(bTime);
    });

    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    final List<String> order = [];

    for (var msg in messages) {
      final ts = msg['timestamp'];
      if (ts == null) continue;

      final date = ts.toDate();
      final key = _getDateLabel(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
        order.add(key);
      }

      grouped[key]!.add(msg);
    }

    return order.map((key) => {"date": key, "messages": grouped[key]}).toList();
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    if (diff <= 7) return _weekdayName(date.weekday);

    return "${date.day}/${date.month}/${date.year}";
  }

  String _weekdayName(int day) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return days[day - 1];
  }

  Widget _dateHeader(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTick(bool isMe, bool isSeen) {
    if (!isMe) return const SizedBox();

    return Icon(
      Icons.done_all,
      size: 18,
      color: isSeen ? Colors.blue : Colors.grey,
    );
  }

  Widget _messageBubble({
    required Map<String, dynamic> msg,
    required bool isMe,
    required String messageId,
    required String chatId,
    required Color otherColor,
    required ThemeData theme,
  }) {
    final time = msg['timestamp'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : otherColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg['message'] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                buildTick(isMe, msg['isSeen'] ?? false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";
    final DateTime date = timestamp.toDate();
    return TimeOfDay.fromDateTime(date).format(context);
  }
}

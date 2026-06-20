import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — all sizes / colours in one place
// ─────────────────────────────────────────────────────────────────────────────
abstract class _D {
  // Bubble colours (WhatsApp exact)
  static const myBubble = Color(0xFFD9FDD3); // light mode mine
  static const myBubbleDark = Color(0xFF025144); // dark mode mine
  static const theirBubble = Colors.white;
  static const theirBubbleDk = Color(0xFF1F2937);

  // Chat background
  static const chatBg = Color(0xFFECE5DD); // WA beige (light)
  static const chatBgDark = Color(0xFF0B0E11);

  // Input bar
  static const barBg = Color(0xFFF0F2F5);
  static const barBgDark = Color(0xFF1A1D23);
  static const pillBg = Colors.white;
  static const pillBgDark = Color(0xFF2A2F38);

  // Radius
  static final myRadius = const BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(4),
  );
  static final theirRadius = const BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );
}

// Converts a DateTime to "h:mm AM/PM" — used by both presence text and bubbles.
String _fmtAmPm(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final period = d.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $period';
}

// ─────────────────────────────────────────────────────────────────────────────
class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key});
  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final _fs = FirebaseFirestore.instance;
  final _me = FirebaseAuth.instance.currentUser;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  late final String _chatId;
  late final String _userName;
  late final String _listingTitle;
  late final String _listingImage;
  late final String _otherUserId;
  late final String _listingId;
  late final String _sellerUid;

  bool _isSending = false;
  bool _isSendingImage = false;
  bool _markingBusy = false;
  bool _isSold = false;
  bool _isMarkingAsSold = false;
  bool _canSendImages = false;
  XFile? _pending;
  Timer? _seenTimer;
  StreamSubscription<DocumentSnapshot>? _listingSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _chatId = args['chatId']?.toString() ?? '';
    _userName = args['userName']?.toString() ?? 'Chat';
    _listingTitle = args['listingTitle']?.toString() ?? '';
    _listingImage = args['listingImage']?.toString() ?? '';
    _otherUserId = args['otherUserId']?.toString() ?? '';
    _listingId = args['listingId']?.toString() ?? '';
    _sellerUid = args['sellerUid']?.toString() ?? '';
    _resetUnread();
    _setPresence(true);
    _subscribeListingStatus();
    _initSubscriptionStatus();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _scrollToBottom(animated: true);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _seenTimer?.cancel();
    _listingSub?.cancel();
    _setPresence(false);
    super.dispose();
  }

  void _initSubscriptionStatus() {
    try {
      final userData = Get.find<AuthController>().userData.value;
      final sub = userData?['subscription'] as Map<String, dynamic>?;
      final plan = SubscriptionService.getPlan(sub);
      final isActive = SubscriptionService.isActive(sub);
      _canSendImages = isActive && plan != RazorpayConfig.planFree;
    } catch (_) {
      _canSendImages = false;
    }
  }

  // Streams the listing's isSold flag so the banner updates in real time.
  void _subscribeListingStatus() {
    if (_listingId.isEmpty) return;
    _listingSub = _fs.collection('listings').doc(_listingId).snapshots().listen(
      (snap) {
        if (!mounted) return;
        final sold = (snap.data() ?? {})['isSold'] as bool? ?? false;
        if (_isSold != sold) setState(() => _isSold = sold);
      },
    );
  }

  Future<void> _markAsSold() async {
    if (_isSold || _isMarkingAsSold || _listingId.isEmpty) return;
    HapticFeedback.mediumImpact();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _MarkSoldDialog(isDark: isDark),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isMarkingAsSold = true);
    try {
      await _fs.collection('listings').doc(_listingId).update({
        'isSold': true,
        'status': 'sold',
        'soldAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('chat_failed_please_try_again'.tr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingAsSold = false);
    }
  }

  // ── Firebase helpers ───────────────────────────────────────────────────────
  Future<void> _setPresence(bool online) async {
    final uid = _me?.uid;
    if (uid == null) return;
    try {
      await _fs.collection('users').doc(uid).update({
        'isOnline': online,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _resetUnread() async {
    if (_chatId.isEmpty) return;
    try {
      await _fs.collection('chats').doc(_chatId).update({'unreadCount': 0});
    } catch (_) {}
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (animated) {
      _scrollCtrl.animateTo(
        max,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(max);
    }
  }

  void _scheduleSeen(List<QueryDocumentSnapshot> msgs) {
    _seenTimer?.cancel();
    _seenTimer = Timer(
      const Duration(milliseconds: 600),
      () => _markSeen(msgs),
    );
  }

  Future<void> _markSeen(List<QueryDocumentSnapshot> msgs) async {
    if (_markingBusy) return;
    _markingBusy = true;
    try {
      final unseen = msgs.where((d) {
        final data = d.data() as Map<String, dynamic>;
        return data['senderId'] != _me!.uid && data['isSeen'] == false;
      }).toList();
      if (unseen.isEmpty) return;
      final batch = _fs.batch();
      for (final d in unseen) {
        batch.update(
          _fs.collection('chats').doc(_chatId).collection('messages').doc(d.id),
          {'isSeen': true},
        );
      }
      batch.update(_fs.collection('chats').doc(_chatId), {
        'isSeen': true,
        'unreadCount': 0,
      });
      await batch.commit();
    } catch (_) {
    } finally {
      _markingBusy = false;
    }
  }

  // ── Attachment picker ──────────────────────────────────────────────────────
  void _showAttachSheet() {
    if (_isSendingImage) return;
    HapticFeedback.lightImpact();
    if (!_canSendImages) {
      _showImageUpgradePrompt();
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachSheet(
        isDark: isDark,
        onCamera: () {
          Navigator.pop(context);
          _pickFrom(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _pickFrom(ImageSource.gallery);
        },
      ),
    );
  }

  void _showImageUpgradePrompt() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageUpgradeSheet(isDark: isDark),
    );
  }

  Future<void> _pickFrom(ImageSource src) async {
    final picked = await ImagePicker().pickImage(
      source: src,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (picked == null || !mounted) return;
    setState(() => _pending = picked);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _clearPending() => setState(() => _pending = null);

  // ── Send ───────────────────────────────────────────────────────────────────
  Future<void> _send() async {
    if (_pending != null) {
      await _sendImage();
    } else {
      await _sendText();
    }
  }

  Future<void> _sendText() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    HapticFeedback.lightImpact();
    setState(() => _isSending = true);
    _msgCtrl.clear();
    try {
      final batch = _fs.batch();
      final ref = _fs
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc();
      batch.set(ref, {
        'senderId': _me!.uid,
        if (_otherUserId.isNotEmpty) 'receiverId': _otherUserId,
        'type': 'text',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isSeen': false,
      });
      batch.update(_fs.collection('chats').doc(_chatId), {
        'lastMessage': text,
        'lastSenderId': _me.uid,
        'isSeen': false,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      });
      await batch.commit();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToBottom(animated: true),
      );
    } catch (_) {
      _msgCtrl.text = text;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('chat_failed_to_send'.tr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendImage() async {
    final img = _pending;
    if (img == null) return;
    final caption = _msgCtrl.text.trim();
    _msgCtrl.clear();
    setState(() {
      _pending = null;
      _isSendingImage = true;
    });
    try {
      final bytes = await FlutterImageCompress.compressWithFile(
        img.path,
        quality: 72,
        minWidth: 800,
        minHeight: 800,
      );
      if (bytes == null) return;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance.ref('chats/$_chatId/images/$ts.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      final batch = _fs.batch();
      final msgRef = _fs
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc();
      batch.set(msgRef, {
        'senderId': _me!.uid,
        if (_otherUserId.isNotEmpty) 'receiverId': _otherUserId,
        'type': 'image',
        'imageUrl': url,
        'caption': caption,
        'message': caption.isEmpty ? '📷 Photo' : caption,
        'timestamp': FieldValue.serverTimestamp(),
        'isSeen': false,
      });
      batch.update(_fs.collection('chats').doc(_chatId), {
        'lastMessage': caption.isEmpty ? '📷 Photo' : '📷 $caption',
        'lastSenderId': _me.uid,
        'isSeen': false,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      });
      await batch.commit();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToBottom(animated: true),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('chat_failed_to_send_image'.tr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingImage = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _D.chatBgDark : _D.chatBg,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          if (_listingTitle.isNotEmpty)
            _ListingBanner(
              title: _listingTitle,
              image: _listingImage,
              isDark: isDark,
              isSeller: _sellerUid.isNotEmpty && _sellerUid == _me?.uid,
              isSold: _isSold,
              isMarking: _isMarkingAsSold,
              onMarkSold: _markAsSold,
            ),
          Expanded(child: _buildList(isDark)),
          if (_isSold) _SoldNotice(isDark: isDark) else _buildInputBar(isDark),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark) {
    final appBarBg = isDark ? const Color(0xFF1A1D23) : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.black87;

    return AppBar(
      elevation: 0,
      backgroundColor: appBarBg,
      titleSpacing: 0,
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: fgColor),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: Get.back,
      ),
      title: _otherUserId.isEmpty
          ? _simpleTitle()
          : StreamBuilder<DocumentSnapshot>(
              stream: _fs.collection('users').doc(_otherUserId).snapshots(),
              builder: (_, snap) {
                final d = snap.data?.data() as Map<String, dynamic>?;
                final online = d?['isOnline'] as bool? ?? false;
                final lastSeen = d?['lastSeen'];
                final photo = d?['photoUrl'] as String? ?? '';
                return _AppBarTitle(
                  name: _userName,
                  photo: photo,
                  online: online,
                  subtitle: _presenceText(online, lastSeen),
                  appBarBg: appBarBg,
                  foregroundColor: fgColor,
                );
              },
            ),
    );
  }

  Widget _simpleTitle() => _AppBarTitle(
    name: _userName,
    photo: '',
    online: false,
    subtitle: '',
    appBarBg: AppColors.primary,
    foregroundColor: Colors.white,
  );

  String _presenceText(bool online, dynamic lastSeen) {
    if (online) return 'chat_online'.tr;
    if (lastSeen == null) return '';
    try {
      final d = (lastSeen as Timestamp).toDate();
      final diff = DateTime.now().difference(d);
      if (diff.inSeconds < 60) return 'chat_last_seen_just_now'.tr;
      if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
      if (diff.inHours < 24) {
        return 'last seen today at ${_fmtAmPm(d)}';
      }
      if (diff.inDays == 1) return 'chat_last_seen_yesterday'.tr;
      return 'last seen ${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  // ── Message list ───────────────────────────────────────────────────────────
  Widget _buildList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fs
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (_, snap) {
        if (snap.hasError) {
          return Center(child: Text('something_went_wrong'.tr));
        }
        if (!snap.hasData) return _RoomShimmer(isDark: isDark);

        final all = snap.data!.docs
            .where((d) => (d.data() as Map)['timestamp'] != null)
            .toList();

        if (all.isEmpty) return _EmptyConvo(isDark: isDark);

        _scheduleSeen(all);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            final pos = _scrollCtrl.position;
            if (pos.maxScrollExtent - pos.pixels < 160) {
              _scrollToBottom(animated: true);
            }
          }
        });

        final groups = _groupByDate(all);

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          itemCount: groups.length,
          itemBuilder: (_, gi) {
            final g = groups[gi];
            final msgs = g['messages'] as List<QueryDocumentSnapshot>;
            return Column(
              children: [
                _DateChip(label: g['date'] as String, isDark: isDark),
                ...msgs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isMe = data['senderId'] == _me!.uid;
                  return _Bubble(data: data, isMe: isMe, isDark: isDark);
                }),
              ],
            );
          },
        );
      },
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────
  Widget _buildInputBar(bool isDark) {
    final barBg = isDark ? _D.barBgDark : _D.barBg;
    final pillBg = isDark ? _D.pillBgDark : _D.pillBg;
    final hint = isDark ? Colors.white38 : const Color(0xFF8E9BAA);
    final attach = isDark ? Colors.white38 : const Color(0xFF8E9BAA);
    final hasPend = _pending != null;
    final busy = _isSending || _isSendingImage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Image preview strip (animated) ────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: hasPend
              ? _ImagePreviewStrip(
                  path: _pending!.path,
                  isDark: isDark,
                  barBg: barBg,
                  isSending: _isSendingImage,
                  onRemove: _clearPending,
                )
              : const SizedBox.shrink(),
        ),

        // ── Input row ─────────────────────────────────────────────────────
        Container(
          color: barBg,
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Pill ──────────────────────────────────────────────────────
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Text field (no inline thumbnail — preview is above)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(26),
                              bottomLeft: Radius.circular(26),
                            ),
                            child: TextField(
                              controller: _msgCtrl,
                              focusNode: _focusNode,
                              minLines: 1,
                              maxLines: 5,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                fontSize: 15.5,
                                height: 1.38,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: hasPend
                                    ? 'chat_add_caption_hint'.tr
                                    : 'message_hint'.tr,
                                hintStyle: TextStyle(
                                  fontSize: 15.5,
                                  color: hint,
                                  height: 1.38,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  4,
                                  14,
                                ),
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                        ),

                        // Attach / upload-spinner
                        SizedBox(
                          width: 44,
                          height: 48,
                          child: Center(
                            child: _isSendingImage
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: hasPend ? null : _showAttachSheet,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 23,
                                          color: hasPend
                                              ? attach.withValues(alpha: 0.3)
                                              : attach,
                                        ),
                                        if (!_canSendImages)
                                          Positioned(
                                            right: -4,
                                            bottom: -4,
                                            child: Container(
                                              width: 13,
                                              height: 13,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF2A2F38)
                                                    : Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.lock_rounded,
                                                size: 9,
                                                color: isDark
                                                    ? Colors.white38
                                                    : Colors.black38,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ── Send button ────────────────────────────────────────────────
                GestureDetector(
                  onTap: busy ? null : _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: busy ? Colors.grey.shade400 : AppColors.primary,
                      boxShadow: busy
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Center(
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ), // closes Container (input row)
      ], // closes Column.children
    ); // closes Column
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _groupByDate(List<QueryDocumentSnapshot> msgs) {
    final map = <String, List<QueryDocumentSnapshot>>{};
    final order = <String>[];
    for (final m in msgs) {
      final ts = m['timestamp'];
      if (ts == null) continue;
      final key = _dateLabel((ts as Timestamp).toDate());
      if (!map.containsKey(key)) {
        map[key] = [];
        order.add(key);
      }
      map[key]!.add(m);
    }
    return order.map((k) => {'date': k, 'messages': map[k]!}).toList();
  }

  String _dateLabel(DateTime d) {
    final today = DateTime.now();
    final diff = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(d.year, d.month, d.day)).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    if (diff < 7) {
      const days = [
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY',
        'SUNDAY',
      ];
      return days[d.weekday - 1];
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar title row
// ─────────────────────────────────────────────────────────────────────────────
class _AppBarTitle extends StatelessWidget {
  final String name;
  final String photo;
  final bool online;
  final String subtitle;
  final Color appBarBg;
  final Color foregroundColor;

  const _AppBarTitle({
    required this.name,
    required this.photo,
    required this.online,
    required this.subtitle,
    required this.appBarBg,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: foregroundColor.withValues(alpha: 0.15),
              ),
              clipBehavior: Clip.antiAlias,
              child: photo.isNotEmpty
                  ? Image.network(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Icon(
                        Icons.person_rounded,
                        color: foregroundColor,
                        size: 20,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: foregroundColor,
                      size: 20,
                    ),
            ),
            if (online)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                    border: Border.all(color: appBarBg, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: online
                        ? const Color(0xFF86EFAC)
                        : foregroundColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Listing banner
// ─────────────────────────────────────────────────────────────────────────────
class _ListingBanner extends StatelessWidget {
  final String title;
  final String image;
  final bool isDark;
  final bool isSeller;
  final bool isSold;
  final bool isMarking;
  final VoidCallback onMarkSold;

  const _ListingBanner({
    required this.title,
    required this.image,
    required this.isDark,
    required this.isSeller,
    required this.isSold,
    required this.isMarking,
    required this.onMarkSold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppCachedImageNetwork(
              height: 36,
              width: 36,
              imageUrl: image,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          // Mark as Sold — visible only to the seller
          if (isSeller) ...[
            const SizedBox(width: 8),
            isSold
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF57C00).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sell_rounded,
                          size: 12,
                          color: const Color(0xFFF57C00),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'sold'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF57C00),
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: isMarking ? null : onMarkSold,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isMarking
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: isMarking
                          ? SizedBox(
                              width: 52,
                              height: 14,
                              child: Center(
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'chat_mark_sold'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date chip
// ─────────────────────────────────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final bool isDark;

  const _Bubble({required this.data, required this.isMe, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final maxW = screenW * 0.76;
    final isImage = data['type'] == 'image';
    final url = data['imageUrl'] as String? ?? '';
    final caption = data['caption'] as String? ?? '';
    final message = data['message'] as String? ?? '';
    final ts = data['timestamp'];
    final isSeen = data['isSeen'] as bool? ?? false;

    final bubbleColor = isMe
        ? (isDark ? _D.myBubbleDark : _D.myBubble)
        : (isDark ? _D.theirBubbleDk : _D.theirBubble);
    final textColor = isDark ? Colors.white : Colors.black87;
    final radius = isMe ? _D.myRadius : _D.theirRadius;

    Widget child;

    if (isImage && url.isNotEmpty) {
      child = _ImageBubble(
        url: url,
        caption: caption,
        isMe: isMe,
        isDark: isDark,
        ts: ts,
        isSeen: isSeen,
        bubbleColor: bubbleColor,
        textColor: textColor,
        radius: radius,
      );
    } else {
      child = _TextBubble(
        text: message,
        isMe: isMe,
        isDark: isDark,
        ts: ts,
        isSeen: isSeen,
        bubbleColor: bubbleColor,
        textColor: textColor,
        radius: radius,
        maxW: maxW,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text bubble — shrinks to content width (true WhatsApp behaviour)
// ─────────────────────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isDark;
  final dynamic ts;
  final bool isSeen;
  final Color bubbleColor;
  final Color textColor;
  final BorderRadius radius;
  final double maxW;

  const _TextBubble({
    required this.text,
    required this.isMe,
    required this.isDark,
    required this.ts,
    required this.isSeen,
    required this.bubbleColor,
    required this.textColor,
    required this.radius,
    required this.maxW,
  });

  @override
  Widget build(BuildContext context) {
    // ConstrainedBox caps max width; IntrinsicWidth shrinks the bubble
    // to only as wide as the widest line of text (or the timestamp row).
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: IntrinsicWidth(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 7, 10, 6),
            child: Column(
              // stretch so Row below fills the IntrinsicWidth column width
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.38,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                // Timestamp always at the right edge of the bubble
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TimeRow(
                      ts: ts,
                      isMe: isMe,
                      isSeen: isSeen,
                      isDark: isDark,
                      onImage: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image bubble
// ─────────────────────────────────────────────────────────────────────────────
class _ImageBubble extends StatelessWidget {
  final String url;
  final String caption;
  final bool isMe;
  final bool isDark;
  final dynamic ts;
  final bool isSeen;
  final Color bubbleColor;
  final Color textColor;
  final BorderRadius radius;

  const _ImageBubble({
    required this.url,
    required this.caption,
    required this.isMe,
    required this.isDark,
    required this.ts,
    required this.isSeen,
    required this.bubbleColor,
    required this.textColor,
    required this.radius,
  });

  // Top-only radius when caption sits below image
  BorderRadius get _imgRadius => caption.isEmpty
      ? radius
      : BorderRadius.only(topLeft: radius.topLeft, topRight: radius.topRight);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    // Compact image: ~57% screen width, capped at 220dp — never dominates chat
    final imgW = (screenW * 0.57).clamp(180.0, 220.0);
    final imgH = imgW; // 1:1 square thumbnail (WhatsApp style compact)

    return GestureDetector(
      onTap: () =>
          Get.to(() => _FullImageView(url: url), transition: Transition.fadeIn),
      child: Container(
        width: imgW,
        decoration: BoxDecoration(
          color: caption.isNotEmpty ? bubbleColor : null,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image ──────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: _imgRadius,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: imgW,
                    height: imgH,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                      width: imgW,
                      height: imgH,
                      color: isDark
                          ? const Color(0xFF2A3140)
                          : Colors.grey.shade200,
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (ctx, url, err) => Container(
                      width: imgW,
                      height: imgH,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                        size: 42,
                      ),
                    ),
                  ),
                ),
                // Timestamp overlay (only when no caption)
                if (caption.isEmpty)
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: _TimeRow(
                      ts: ts,
                      isMe: isMe,
                      isSeen: isSeen,
                      isDark: isDark,
                      onImage: true,
                    ),
                  ),
              ],
            ),

            // ── Caption ────────────────────────────────────────────────
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 7, 11, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.38,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _TimeRow(
                        ts: ts,
                        isMe: isMe,
                        isSeen: isSeen,
                        isDark: isDark,
                        onImage: false,
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

// ─────────────────────────────────────────────────────────────────────────────
// Timestamp + tick row
// ─────────────────────────────────────────────────────────────────────────────
class _TimeRow extends StatelessWidget {
  final dynamic ts;
  final bool isMe;
  final bool isSeen;
  final bool isDark;
  final bool onImage;

  const _TimeRow({
    required this.ts,
    required this.isMe,
    required this.isSeen,
    required this.isDark,
    required this.onImage,
  });

  String _fmt() {
    if (ts == null) return '';
    try {
      return _fmtAmPm((ts as Timestamp).toDate());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _fmt();
    final timeColor = onImage
        ? Colors.white
        : (isDark ? Colors.white38 : const Color(0xFF8E9BAA));
    final tickColor = isSeen
        ? const Color(0xFF53BDEB)
        : (onImage ? Colors.white70 : const Color(0xFF8E9BAA));

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: timeColor,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 3),
          Icon(Icons.done_all_rounded, size: 15, color: tickColor),
        ],
      ],
    );

    if (!onImage) return row;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: row,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen image viewer
// ─────────────────────────────────────────────────────────────────────────────
class _FullImageView extends StatelessWidget {
  final String url;
  const _FullImageView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: Get.back,
        ),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 8.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (ctx, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
            errorWidget: (ctx, url, err) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white38,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image preview strip — shown ABOVE the input bar when a photo is selected
// ─────────────────────────────────────────────────────────────────────────────
class _ImagePreviewStrip extends StatelessWidget {
  final String path;
  final bool isDark;
  final Color barBg;
  final bool isSending;
  final VoidCallback onRemove;

  const _ImagePreviewStrip({
    required this.path,
    required this.isDark,
    required this.barBg,
    required this.isSending,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final subColor = isDark ? Colors.white38 : Colors.grey.shade500;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(path),
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                ),
              ),
              if (isSending)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black45,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'chat_one_photo'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isSending ? 'chat_uploading'.tr : 'chat_add_caption_below'.tr,
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
              ],
            ),
          ),

          // Remove button
          if (!isSending)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attach source bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AttachSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _AttachSheet({
    required this.isDark,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E222A) : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SheetOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'camera'.tr,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: onCamera,
                ),
                _SheetOption(
                  icon: Icons.photo_library_rounded,
                  label: 'gallery'.tr,
                  color: const Color(0xFF6C63FF),
                  isDark: isDark,
                  onTap: onGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty conversation
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyConvo extends StatelessWidget {
  final bool isDark;
  const _EmptyConvo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? const Color(0xFF4ADE80) : AppColors.primary;
    final subColor = isDark ? Colors.white38 : Colors.black38;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.15 : 0.12),
                  accent.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'chat_no_messages_yet'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'chat_say_hi_to_start'.tr,
            style: TextStyle(fontSize: 13, color: subColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mark as sold confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────
class _MarkSoldDialog extends StatelessWidget {
  final bool isDark;
  const _MarkSoldDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C1F28) : Colors.white;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF57C00).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.sell_rounded,
                color: Color(0xFFF57C00),
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'chat_mark_as_sold_title'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'chat_mark_sold_body'.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.hintColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'chat_mark_sold'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sold notice — replaces the input bar once the listing is marked sold
// ─────────────────────────────────────────────────────────────────────────────
class _SoldNotice extends StatelessWidget {
  final bool isDark;
  const _SoldNotice({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1D23) : const Color(0xFFF8F8F8);
    final textColor = isDark ? Colors.white54 : Colors.black45;

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sell_rounded, size: 16, color: Color(0xFFF57C00)),
            const SizedBox(width: 8),
            Text(
              'chat_listing_sold'.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image upgrade prompt — shown when free-plan users tap the image button
// ─────────────────────────────────────────────────────────────────────────────
class _ImageUpgradeSheet extends StatelessWidget {
  final bool isDark;
  const _ImageUpgradeSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E222A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    const accent = AppColors.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.15),
                        accent.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.image_rounded, size: 28, color: accent),
                      Positioned(
                        right: 9,
                        bottom: 9,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Title
                Text(
                  'chat_photos_images'.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 7),
                // Body
                Text(
                  'chat_upgrade_for_images'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.5, color: subColor),
                ),
                const SizedBox(height: 10),
                // Plan pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UpgradePill(
                      label: 'chat_plus_price'.tr,
                      color: accent,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _UpgradePill(
                      label: 'chat_pro_price'.tr,
                      color: const Color(0xFFF57C00),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.subscription);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'chat_view_plans'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'maybe_later'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      color: subColor,
                      fontWeight: FontWeight.w500,
                    ),
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

class _UpgradePill extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _UpgradePill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer for chat room
// ─────────────────────────────────────────────────────────────────────────────
class _RoomShimmer extends StatelessWidget {
  final bool isDark;
  const _RoomShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF1E2430) : Colors.grey.shade300;
    final hi = isDark ? const Color(0xFF2A3140) : Colors.grey.shade100;
    final fill = isDark ? const Color(0xFF252A35) : Colors.white;

    const rows = [
      (isMe: false, w: 200.0, h: 48.0),
      (isMe: true, w: 150.0, h: 36.0),
      (isMe: false, w: 220.0, h: 72.0),
      (isMe: true, w: 240.0, h: 48.0),
      (isMe: false, w: 160.0, h: 36.0),
      (isMe: true, w: 190.0, h: 60.0),
    ];

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(
            child: Container(
              height: 22,
              width: 80,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: r.isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: r.w,
                  height: r.h,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

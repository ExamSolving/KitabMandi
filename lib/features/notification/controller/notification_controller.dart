import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../model/notification_model.dart';

class NotificationController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;
  final notificationsEnabled = true.obs;

  static const _kNotifEnabled = 'notif_enabled';

  StreamSubscription<QuerySnapshot>? _notifSub;
  StreamSubscription<User?>? _authSub;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    notificationsEnabled.value =
        Hive.box('settingsBox').get(_kNotifEnabled, defaultValue: true) as bool;
    // React to login / logout for the lifetime of the controller
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToUser(user.uid);
      } else {
        _cancelStream();
        notifications.clear();
        isLoading.value = false;
      }
    });
  }

  @override
  void onClose() {
    _cancelStream();
    _authSub?.cancel();
    super.onClose();
  }

  // ── Notification toggle ───────────────────────────────────────────────────

  /// Persists the preference and adds/removes the FCM token from Firestore so
  /// the server stops (or resumes) sending push alerts.
  /// The in-app notification page and badge are unaffected either way.
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    Hive.box('settingsBox').put(_kNotifEnabled, enabled);
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      if (enabled) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _db.collection('users').doc(uid).update({'fcmToken': token});
        }
      } else {
        await _db
            .collection('users')
            .doc(uid)
            .update({'fcmToken': FieldValue.delete()});
      }
    } catch (_) {}
  }

  // ── Firestore stream ──────────────────────────────────────────────────────

  void _subscribeToUser(String uid) {
    _cancelStream();
    isLoading.value = true;

    _notifSub = _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snap) {
        notifications.value =
            snap.docs.map(NotificationModel.fromFirestore).toList();
        isLoading.value = false;
      },
      onError: (Object e) {
        debugPrint('[Notif] stream error: $e');
        isLoading.value = false;
      },
    );
  }

  void _cancelStream() {
    _notifSub?.cancel();
    _notifSub = null;
  }

  CollectionReference<Map<String, dynamic>>? _notifCol() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('notifications');
  }

  // ── FCM write (called by FCMService) ──────────────────────────────────────

  /// Handles an incoming FCM message.
  /// Cloud Functions already write the notification to Firestore before
  /// sending the push (indicated by notif_saved == 'true'), so we skip the
  /// Firestore write to avoid duplicates. The real-time stream picks up the
  /// Cloud Function's document automatically.
  Future<void> addFromFCM(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    // Cloud Function already persisted this notification — nothing to write.
    if (message.data['notif_saved'] == 'true') return;

    // Fallback: notification came from a source other than our Cloud Functions
    // (e.g. Firebase Console test message). Persist it ourselves.
    final col = _notifCol();
    if (col == null) return;

    final id = message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    if (notifications.any((e) => e.id == id)) return;

    final model = NotificationModel(
      id: id,
      title: n.title ?? 'Notification',
      body: n.body ?? '',
      type: NotifType.fromString(
          message.data['type'] as String? ?? 'system'),
      isRead: false,
      createdAt: DateTime.now(),
      payload: message.data.isNotEmpty
          ? Map<String, dynamic>.from(message.data)
          : null,
    );

    try {
      await col.doc(id).set(model.toMap());
    } catch (e) {
      debugPrint('[Notif] addFromFCM write error: $e');
    }
  }

  // ── Mutations (optimistic local update + Firestore write) ─────────────────

  Future<void> markRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !notifications[idx].isRead) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
      notifications.refresh();
    }
    try {
      await _notifCol()?.doc(id).update({'isRead': true});
    } catch (e) {
      debugPrint('[Notif] markRead error: $e');
    }
  }

  Future<void> markAllRead() async {
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();

    final col = _notifCol();
    if (col == null) return;
    try {
      final batch = _db.batch();
      for (final n in notifications) {
        batch.update(col.doc(n.id), {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[Notif] markAllRead error: $e');
    }
  }

  Future<void> remove(String id) async {
    notifications.removeWhere((n) => n.id == id);
    try {
      await _notifCol()?.doc(id).delete();
    } catch (e) {
      debugPrint('[Notif] remove error: $e');
    }
  }
}

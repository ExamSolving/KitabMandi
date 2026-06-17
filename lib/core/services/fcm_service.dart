import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing_details/binding/listing_details_binding.dart';
import 'package:kitab_mandi/features/listing_details/view/listing_details_view.dart';
import 'package:kitab_mandi/features/notification/controller/notification_controller.dart';
import 'package:kitab_mandi/firebase_options.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

// ── Background handler — must be a top-level function ─────────────────────────
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

// ─────────────────────────────────────────────────────────────────────────────
// FCMService — handles foreground, background and terminated notification states
// ─────────────────────────────────────────────────────────────────────────────
class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  static const _channelId = 'kitabmandi_high';
  static const _channelName = 'KitabMandi';
  static const _channelDesc = 'Book buy/sell alerts and messages';

  final _plugin = FlutterLocalNotificationsPlugin();
  RemoteMessage? _pendingMessage; // set when app was launched from notification

  // ── Public entry point ────────────────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Register top-level background handler
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

    // 2. Permission request
    await _requestPermission();

    // 3. Local notification plugin (foreground display)
    await _initLocalNotifications();

    // 4. iOS — show alert/badge/sound even when app is in foreground
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Foreground message stream
    FirebaseMessaging.onMessage.listen(_onForeground);

    // 6. Background → tap opens app
    FirebaseMessaging.onMessageOpenedApp.listen(_onBackgroundTap);

    // 7. Terminated → tap launched app (stored for later consumption)
    _pendingMessage = await FirebaseMessaging.instance.getInitialMessage();

    // 8. Auto-save token whenever auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _saveToken(user.uid);
    });
  }

  /// Call this from the dashboard once it is fully rendered.
  /// Navigates to the right screen if the app was opened from a notification.
  void consumePendingNavigation() {
    if (_pendingMessage == null) return;
    // Small delay so the dashboard route is settled before we push.
    Future.delayed(const Duration(milliseconds: 1200), () {
      final msg = _pendingMessage;
      _pendingMessage = null;
      if (msg != null) {
        _pushToController(msg);
        _navigateFromData(msg.data);
      }
    });
  }

  // ── Internal handlers ─────────────────────────────────────────────────────

  Future<void> _onForeground(RemoteMessage message) async {
    debugPrint('[FCM] Foreground: ${message.notification?.title}');
    _pushToController(message);
    await _showLocalNotification(message);
  }

  void _onBackgroundTap(RemoteMessage message) {
    debugPrint('[FCM] Background tap: ${message.data}');
    _pushToController(message);
    _navigateFromData(message.data);
  }

  // ── Local notifications ───────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!) as Map<String, dynamic>;
            _navigateFromData(data);
          } catch (_) {}
        }
      },
    );

    // Create Android high-importance channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    await _plugin.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          ticker: n.title,
          styleInformation: BigTextStyleInformation(n.body ?? ''),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Auth status: ${settings.authorizationStatus}');
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<void> _saveToken(String uid) async {
    try {
      // On iOS, the APNs token must arrive before Firebase can generate an
      // FCM token. Poll up to 5 times (10 s total) then give up gracefully.
      if (Platform.isIOS) {
        String? apns;
        for (int i = 0; i < 5; i++) {
          apns = await FirebaseMessaging.instance.getAPNSToken();
          if (apns != null) break;
          await Future.delayed(const Duration(seconds: 2));
        }
        if (apns == null) {
          debugPrint('[FCM] APNs token unavailable — skipping token save');
          return;
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      // Use update() so we never create a ghost document for a deleted account.
      // If the document doesn't exist Firestore throws NOT_FOUND — caught below.
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });

      // Keep token fresh if Firebase rotates it
      FirebaseMessaging.instance.onTokenRefresh.listen((fresh) {
        FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': fresh,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      });

      debugPrint('[FCM] Token saved for $uid');
    } catch (e) {
      debugPrint('[FCM] Token save error: $e');
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _pushToController(RemoteMessage message) {
    try {
      final ctrl = Get.find<NotificationController>();
      ctrl.addFromFCM(message);
    } catch (_) {
      // NotificationController not yet in the widget tree — safe to ignore
    }
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'system';
    switch (type) {
      case 'chat':
        final chatId = data['chat_id'] as String?;
        if (chatId != null) {
          Get.toNamed(AppRoutes.chatRoom, arguments: {
            'chatId': chatId,
            'userName': data['sender_name'] ?? '',
            'listingTitle': data['listing_title'] ?? '',
            'listingImage': '',
            'otherUserId': data['sender_id'] ?? '',
          });
        } else {
          Get.toNamed(AppRoutes.chatView);
        }
        break;
      case 'listing':
      case 'offer':
        final listingId = data['listing_id'] as String?;
        if (listingId != null) {
          _openListing(listingId);
        } else {
          Get.toNamed(AppRoutes.notifications);
        }
        break;
      default:
        Get.toNamed(AppRoutes.notifications);
    }
  }

  // Fetches the listing from Firestore then pushes ListingDetailsView.
  // Using Get.to() (not named route) so we can pass the full ListingModel
  // object — the named route variant requires Get.find() which won't work
  // when navigating from a cold start notification.
  Future<void> _openListing(String listingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .get();
      if (!doc.exists) {
        Get.toNamed(AppRoutes.notifications);
        return;
      }
      final listing = ListingModel.fromMap(doc.data()!, doc.id);
      Get.to(
        () => ListingDetailsView(listing: listing, docId: listingId),
        binding: ListingDetailsBinding(),
      );
    } catch (_) {
      Get.toNamed(AppRoutes.notifications);
    }
  }
}

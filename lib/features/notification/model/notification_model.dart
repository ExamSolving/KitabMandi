import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.payload,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      type: NotifType.fromString(d['type'] as String? ?? 'system'),
      isRead: d['isRead'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      payload: d['payload'] != null
          ? Map<String, dynamic>.from(d['payload'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
        if (payload != null && payload!.isNotEmpty) 'payload': payload,
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        payload: payload,
      );
}

enum NotifType {
  chat,
  listing,
  offer,
  system;

  static NotifType fromString(String raw) {
    switch (raw) {
      case 'chat':
        return NotifType.chat;
      case 'listing':
        return NotifType.listing;
      case 'offer':
        return NotifType.offer;
      default:
        return NotifType.system;
    }
  }
}

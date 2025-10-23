import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { announcement, assignment, grade, attendance, general }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String senderId;
  final String senderName;
  final List<String> recipientIds;
  final Map<String, dynamic>? data; // Additional data for specific notification types
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.recipientIds,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.general,
      ),
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      recipientIds: List<String>.from(data['recipientIds'] ?? []),
      data: data['data'] as Map<String, dynamic>?,
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'senderId': senderId,
      'senderName': senderName,
      'recipientIds': recipientIds,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    NotificationType? type,
    String? senderId,
    String? senderName,
    List<String>? recipientIds,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientIds: recipientIds ?? this.recipientIds,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // Mark notification as read
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }
}
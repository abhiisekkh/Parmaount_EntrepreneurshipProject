import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';
import '../config/firebase_config.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== INITIALIZATION ==============

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Notification permission status: ${settings.authorizationStatus}');
      }

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null && kDebugMode) {
        print('FCM Token: $token');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification when app is terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  // Save FCM token to Firestore for user
  static Future<void> saveFCMToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userId)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  // ============== MESSAGE HANDLERS ==============

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
    }

    // You can show in-app notification here
    _showInAppNotification(message);
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.messageId}');
    }

    // Navigate to specific screen based on notification data
    _navigateBasedOnNotification(message);
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Background message received: ${message.messageId}');
    }
    
    // Save notification to local storage or Firestore
    await _saveNotificationToFirestore(message);
  }

  // ============== SEND NOTIFICATIONS ==============

  // Send notification to specific user
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    required String senderId,
    required String senderName,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      // Create notification model
      NotificationModel notification = NotificationModel(
        id: '',
        title: title,
        message: message,
        type: type,
        senderId: senderId,
        senderName: senderName,
        recipientIds: [userId],
        data: data,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );

      // Save to Firestore
      String notificationId = await DatabaseService.createNotification(notification);

      // Get user's FCM token
      DocumentSnapshot userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? fcmToken = userData['fcmToken'];

        if (fcmToken != null) {
          // Send FCM message
          await _sendFCMMessage(
            token: fcmToken,
            title: title,
            body: message,
            data: {
              'notificationId': notificationId,
              'type': type.toString().split('.').last,
              'senderId': senderId,
              'actionUrl': actionUrl ?? '',
              ...?data,
            },
          );
        }
      }
    } catch (e) {
      throw 'Failed to send notification: $e';
    }
  }

  // Send notification to multiple users
  static Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String message,
    required NotificationType type,
    required String senderId,
    required String senderName,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      // Create notification model
      NotificationModel notification = NotificationModel(
        id: '',
        title: title,
        message: message,
        type: type,
        senderId: senderId,
        senderName: senderName,
        recipientIds: userIds,
        data: data,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );

      // Save to Firestore
      String notificationId = await DatabaseService.createNotification(notification);

      // Get users' FCM tokens
      QuerySnapshot usersSnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      List<String> fcmTokens = [];
      for (QueryDocumentSnapshot doc in usersSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        String? fcmToken = userData['fcmToken'];
        if (fcmToken != null) {
          fcmTokens.add(fcmToken);
        }
      }

      if (fcmTokens.isNotEmpty) {
        // Send FCM message to multiple tokens
        await _sendFCMMessageToMultiple(
          tokens: fcmTokens,
          title: title,
          body: message,
          data: {
            'notificationId': notificationId,
            'type': type.toString().split('.').last,
            'senderId': senderId,
            'actionUrl': actionUrl ?? '',
            ...?data,
          },
        );
      }
    } catch (e) {
      throw 'Failed to send notification to users: $e';
    }
  }

  // Send notification to all users by role
  static Future<void> sendNotificationToRole({
    required String role, // 'student', 'teacher', 'admin'
    required String title,
    required String message,
    required NotificationType type,
    required String senderId,
    required String senderName,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      // Get users by role
      QuerySnapshot usersSnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('role', isEqualTo: role)
          .get();

      List<String> userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      if (userIds.isNotEmpty) {
        await sendNotificationToUsers(
          userIds: userIds,
          title: title,
          message: message,
          type: type,
          senderId: senderId,
          senderName: senderName,
          data: data,
          imageUrl: imageUrl,
          actionUrl: actionUrl,
        );
      }
    } catch (e) {
      throw 'Failed to send notification to role: $e';
    }
  }

  // ============== SPECIFIC NOTIFICATION TYPES ==============

  // Send assignment notification
  static Future<void> sendAssignmentNotification({
    required List<String> studentIds,
    required String assignmentTitle,
    required DateTime dueDate,
    required String teacherName,
    required String teacherId,
    required String assignmentId,
  }) async {
    await sendNotificationToUsers(
      userIds: studentIds,
      title: 'New Assignment: $assignmentTitle',
      message: 'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year} by $teacherName',
      type: NotificationType.assignment,
      senderId: teacherId,
      senderName: teacherName,
      data: {
        'assignmentId': assignmentId,
        'dueDate': dueDate.toIso8601String(),
      },
      actionUrl: '/assignment/$assignmentId',
    );
  }

  // Send attendance notification
  static Future<void> sendAttendanceNotification({
    required String studentId,
    required String subject,
    required bool isPresent,
    required String teacherName,
    required String teacherId,
  }) async {
    String status = isPresent ? 'Present' : 'Absent';
    await sendNotificationToUser(
      userId: studentId,
      title: 'Attendance Marked',
      message: 'You were marked $status in $subject by $teacherName',
      type: NotificationType.attendance,
      senderId: teacherId,
      senderName: teacherName,
      data: {
        'subject': subject,
        'isPresent': isPresent,
      },
    );
  }

  // Send grade notification
  static Future<void> sendGradeNotification({
    required String studentId,
    required String assignmentTitle,
    required int marksObtained,
    required int totalMarks,
    required String teacherName,
    required String teacherId,
    required String assignmentId,
  }) async {
    await sendNotificationToUser(
      userId: studentId,
      title: 'Assignment Graded',
      message: '$assignmentTitle: $marksObtained/$totalMarks by $teacherName',
      type: NotificationType.grade,
      senderId: teacherId,
      senderName: teacherName,
      data: {
        'assignmentId': assignmentId,
        'marksObtained': marksObtained,
        'totalMarks': totalMarks,
      },
      actionUrl: '/assignment/$assignmentId',
    );
  }

  // Send announcement
  static Future<void> sendAnnouncement({
    required String title,
    required String message,
    required String senderId,
    required String senderName,
    List<String>? targetRoles, // ['student', 'teacher'] or null for all
    String? imageUrl,
  }) async {
    if (targetRoles == null || targetRoles.isEmpty) {
      // Send to all users
      QuerySnapshot allUsers = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .get();
      
      List<String> allUserIds = allUsers.docs.map((doc) => doc.id).toList();
      
      await sendNotificationToUsers(
        userIds: allUserIds,
        title: title,
        message: message,
        type: NotificationType.announcement,
        senderId: senderId,
        senderName: senderName,
        imageUrl: imageUrl,
      );
    } else {
      // Send to specific roles
      for (String role in targetRoles) {
        await sendNotificationToRole(
          role: role,
          title: title,
          message: message,
          type: NotificationType.announcement,
          senderId: senderId,
          senderName: senderName,
          imageUrl: imageUrl,
        );
      }
    }
  }

  // ============== HELPER METHODS ==============

  // Send FCM message to single token
  static Future<void> _sendFCMMessage({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // This would typically use Firebase Admin SDK on server
      // For now, we'll just log the attempt
      if (kDebugMode) {
        print('Would send FCM message to $token: $title - $body');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM message: $e');
      }
    }
  }

  // Send FCM message to multiple tokens
  static Future<void> _sendFCMMessageToMultiple({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // This would typically use Firebase Admin SDK on server
      // For now, we'll just log the attempt
      if (kDebugMode) {
        print('Would send FCM message to ${tokens.length} tokens: $title - $body');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM message to multiple: $e');
      }
    }
  }

  // Show in-app notification
  static void _showInAppNotification(RemoteMessage message) {
    // Implement in-app notification display
    // You can use packages like flutter_local_notifications
    if (kDebugMode) {
      print('Showing in-app notification: ${message.notification?.title}');
    }
  }

  // Navigate based on notification
  static void _navigateBasedOnNotification(RemoteMessage message) {
    Map<String, dynamic> data = message.data;
    String? actionUrl = data['actionUrl'];
    
    if (actionUrl != null && actionUrl.isNotEmpty) {
      // Implement navigation logic based on actionUrl
      if (kDebugMode) {
        print('Navigate to: $actionUrl');
      }
    }
  }

  // Save notification to Firestore
  static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      Map<String, dynamic> data = message.data;
      
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .add({
        'title': message.notification?.title ?? '',
        'message': message.notification?.body ?? '',
        'data': data,
        'receivedAt': FieldValue.serverTimestamp(),
        'messageId': message.messageId,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification to Firestore: $e');
      }
    }
  }

  // ============== USER NOTIFICATION MANAGEMENT ==============

  // Get notifications for user
  static Future<List<NotificationModel>> getUserNotifications(String userId) async {
    return await DatabaseService.getNotificationsForUser(userId);
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await DatabaseService.markNotificationAsRead(notificationId);
  }

  // Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('recipientIds', arrayContains: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get notification stream for user
  static Stream<List<NotificationModel>> getNotificationStream(String userId) {
    return DatabaseService.getNotificationsStreamForUser(userId);
  }

  // Clear all notifications for user
  static Future<void> clearAllNotifications(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('recipientIds', arrayContains: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to clear notifications: $e';
    }
  }
}
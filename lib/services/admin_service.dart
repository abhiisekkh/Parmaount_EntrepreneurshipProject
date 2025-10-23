import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../models/class_model.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../config/firebase_config.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== USER MANAGEMENT ==============

  // Check if email already exists
  static Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false; // If we can't check, proceed with creation
    }
  }

  // Get all users with pagination
  static Future<List<UserModel>> getAllUsers({
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseConfig.usersCollection)
          .orderBy('name')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get users: $e';
    }
  }

  // Enhanced Create User Method with Email Notifications
  static Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
    String? studentId,
    String? teacherId,
    String? course,
    int? semester,
    String? department,
    List<String>? subjectsTaught,
    List<String>? classesAssigned,
  }) async {
    try {
      print('--- DEBUG: AdminService.createUser START ---');
      print('Input Data - Email: $email, Role: ${role.name}, Name: $name');
      print('Phone: $phoneNumber, StudentId: $studentId, TeacherId: $teacherId');
      print('Course: $course, Semester: $semester, Department: $department');
      print('SubjectsTaught: $subjectsTaught, ClassesAssigned: $classesAssigned');

      // 1. Verify admin permission first
      print('ℹ️ DEBUG: Checking admin permissions...');
      if (!await AuthService.isAdmin()) {
        print('❌ DEBUG: Admin permission check failed');
        throw Exception('Access denied. Only administrators can create user accounts.');
      }

      print('✅ DEBUG: Admin permission verified');

      // 2. Validate input data
      print('ℹ️ DEBUG: Validating input data...');
      if (email.trim().isEmpty || !email.contains('@')) {
        print('❌ DEBUG: Invalid email validation failed');
        throw Exception('Please provide a valid email address.');
      }
      
      if (password.trim().isEmpty || password.length < 6) {
        print('❌ DEBUG: Password validation failed');
        throw Exception('Password must be at least 6 characters long.');
      }

      if (name.trim().isEmpty) {
        print('❌ DEBUG: Name validation failed');
        throw Exception('Please provide the user\'s full name.');
      }

      print('✅ DEBUG: Input validation passed');

      // 3. Check if email already exists
      print('ℹ️ DEBUG: Checking email availability...');
      bool emailAlreadyExists = await emailExists(email);
      if (emailAlreadyExists) {
        print('❌ DEBUG: Email already exists in database');
        throw Exception('An account with email "${email.trim()}" already exists. Please use a different email address.');
      }

      print('✅ DEBUG: Email availability verified');

      // 4. Create Firebase Auth user
      print('ℹ️ DEBUG: Calling AuthService.createUserWithEmailAndPassword...');
      UserModel? newUser = await AuthService.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
        name: name.trim(),
        phone: phoneNumber,
        role: role,
        studentId: studentId,
        teacherId: teacherId,
        course: course,
        semester: semester,
        subjectsTaught: subjectsTaught ?? [],
        classesAssigned: classesAssigned ?? [],
      );
      
      print('ℹ️ DEBUG: AuthService.createUserWithEmailAndPassword returned');

      if (newUser == null) {
        print('❌ DEBUG: AuthService.createUser returned null');
        throw Exception('User creation failed in AuthService (returned null).');
      }

      print('✅ DEBUG: User creation successful in AuthService. User UID: ${newUser.uid}');

      // 5. Send welcome email notification (placeholder for Cloud Function)
      print('ℹ️ DEBUG: Sending welcome email...');
      try {
        await _sendWelcomeEmail(
          userEmail: email.trim(),
          userName: name.trim(),
          initialPassword: password,
          userRole: role,
        );
        print('✅ DEBUG: Welcome email sent successfully');
      } catch (emailError) {
        print('⚠️ DEBUG: Welcome email failed: $emailError');
        // Don't throw error for email failure
      }

      // 6. Send in-app notification
      print('ℹ️ DEBUG: Sending in-app notification...');
      try {
        await NotificationService.sendNotificationToUser(
          userId: newUser.uid,
          title: 'Welcome to Paramount Institute! 🎉',
          message: 'Your ${role.name} account has been created successfully. Please check your email for login instructions.',
          type: NotificationType.general,
          senderId: AuthService.currentUser?.uid ?? 'admin',
          senderName: 'Paramount Administration',
        );
        print('✅ DEBUG: In-app notification sent successfully');
      } catch (notifError) {
        print('⚠️ DEBUG: In-app notification failed: $notifError');
        // Don't throw error for notification failure
      }

      print('✅ DEBUG: User creation process completed successfully! 🎉');
      print('--- DEBUG: AdminService.createUser END (Success) ---');
      return newUser;

    } catch (e, stackTrace) { // Catch errors from AdminService or AuthService
      print('❌ DEBUG: Error caught in AdminService.createUser: $e');
      print('❌ DEBUG: Exception Type: ${e.runtimeType}');
      if (e is! Exception) { // Log stack trace only for unexpected errors
        print('ℹ️ DEBUG: StackTrace: $stackTrace');
      }
      print('--- DEBUG: AdminService.createUser END (Error) ---');

      // Re-throw the exception after logging, potentially simplifying it
      if (e.toString().contains('email-already-in-use')) {
        throw Exception('An account with this email address already exists.');
      } else if (e.toString().contains('weak-password')) {
        throw Exception('The password is too weak. Please use a stronger password.');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('The email address is not valid.');
      } else if (e.toString().contains('network-request-failed')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e is Exception) {
        throw e; // Throw the original structured Exception
      } else {
        throw Exception(e.toString().replaceAll('Exception: ', '')); // Throw simplified message
      }
    }
  }

  // Private method to send welcome email (placeholder for Cloud Function)
  static Future<void> _sendWelcomeEmail({
    required String userEmail,
    required String userName,
    required String initialPassword,
    required UserRole userRole,
  }) async {
    try {
      print('📧 Preparing welcome email for: $userEmail');
      
      // TODO: Implement Cloud Function call here
      // For now, this is a placeholder that logs the email content
      
      final emailContent = '''
🎓 Welcome to Paramount Institute!

Hi $userName,

Your ${userRole.name} account has been successfully created!

📧 Login Email: $userEmail
🔐 Initial Password: $initialPassword

🔒 IMPORTANT SECURITY NOTICE:
For your account security, please change your password immediately after your first login.

To change your password:
1. Sign in using the credentials above
2. Go to your Profile settings
3. Select "Change Password"
4. Create a strong, unique password

Welcome to the Paramount family! 🌟

Best regards,
Paramount Institute Administration
      ''';

      print('Email content prepared:');
      print(emailContent);
      
      // TODO: Replace with actual Cloud Function call
      // Example: await _callSendEmailCloudFunction(userEmail, emailContent);
      
      print('✅ Welcome email queued for: $userEmail');
      
    } catch (e) {
      print('⚠️  Failed to send welcome email: $e');
      // Don't throw error for email failure - user creation should still succeed
    }
  }

  // Update user information
  static Future<void> updateUser({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
    String? course,
    int? semester,
    List<String>? subjectsTaught,
    List<String>? classesAssigned,
  }) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can update users';
      }

      await AuthService.updateUserProfile(
        userId: userId,
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
        course: course,
        semester: semester,
        subjectsTaught: subjectsTaught,
        classesAssigned: classesAssigned,
      );
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  // Deactivate user
  static Future<void> deactivateUser(String userId) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can deactivate users';
      }

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update({
        'isActive': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      await NotificationService.sendNotificationToUser(
        userId: userId,
        title: 'Account Deactivated',
        message: 'Your account has been deactivated. Please contact admin for assistance.',
        type: NotificationType.general,
        senderId: AuthService.currentUser?.uid ?? 'admin',
        senderName: 'Paramount Admin',
      );
    } catch (e) {
      throw 'Failed to deactivate user: $e';
    }
  }

  // Reactivate user
  static Future<void> reactivateUser(String userId) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can reactivate users';
      }

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update({
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Send welcome back notification
      await NotificationService.sendNotificationToUser(
        userId: userId,
        title: 'Account Reactivated',
        message: 'Welcome back! Your account has been reactivated.',
        type: NotificationType.general,
        senderId: AuthService.currentUser?.uid ?? 'admin',
        senderName: 'Paramount Admin',
      );
    } catch (e) {
      throw 'Failed to reactivate user: $e';
    }
  }

  // ============== SUBJECT MANAGEMENT ==============

  // Create new subject
  static Future<String> createSubject({
    required String subjectCode,
    required String subjectName,
    required String description,
    required int credits,
    required String semester,
    required String course,
    required String teacherId,
    required String teacherName,
    List<String>? enrolledStudents,
    Map<String, dynamic>? schedule,
  }) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can create subjects';
      }

      SubjectModel subject = SubjectModel(
        id: '',
        subjectCode: subjectCode,
        subjectName: subjectName,
        description: description,
        credits: credits,
        semester: semester,
        course: course,
        teacherId: teacherId,
        teacherName: teacherName,
        enrolledStudents: enrolledStudents ?? [],
        schedule: schedule ?? {},
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      String subjectId = await DatabaseService.createSubject(subject);

      // Notify teacher about new subject assignment
      await NotificationService.sendNotificationToUser(
        userId: teacherId,
        title: 'New Subject Assigned',
        message: 'You have been assigned to teach $subjectName',
        type: NotificationType.general,
        senderId: AuthService.currentUser?.uid ?? 'admin',
        senderName: 'Paramount Admin',
        data: {'subjectId': subjectId},
      );

      return subjectId;
    } catch (e) {
      throw 'Failed to create subject: $e';
    }
  }

  // Update subject
  static Future<void> updateSubject(SubjectModel subject) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can update subjects';
      }

      await DatabaseService.updateSubject(subject);
    } catch (e) {
      throw 'Failed to update subject: $e';
    }
  }

  // Delete subject
  static Future<void> deleteSubject(String subjectId) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can delete subjects';
      }

      await _firestore
          .collection(FirebaseConfig.subjectsCollection)
          .doc(subjectId)
          .update({
        'isActive': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to delete subject: $e';
    }
  }

  // ============== CLASS MANAGEMENT ==============

  // Create new class
  static Future<String> createClass({
    required String className,
    required String subjectId,
    required String subjectName,
    required String teacherId,
    required String teacherName,
    required DateTime startTime,
    required DateTime endTime,
    required String room,
    required String semester,
    required String course,
    List<String>? enrolledStudents,
  }) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can create classes';
      }

      ClassModel classModel = ClassModel(
        id: '',
        className: className,
        subjectId: subjectId,
        subjectName: subjectName,
        teacherId: teacherId,
        teacherName: teacherName,
        startTime: startTime,
        endTime: endTime,
        room: room,
        semester: semester,
        course: course,
        enrolledStudents: enrolledStudents ?? [],
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      String classId = await DatabaseService.createClass(classModel);

      // Notify teacher about new class
      await NotificationService.sendNotificationToUser(
        userId: teacherId,
        title: 'New Class Scheduled',
        message: '$className scheduled for ${startTime.day}/${startTime.month}/${startTime.year}',
        type: NotificationType.general,
        senderId: AuthService.currentUser?.uid ?? 'admin',
        senderName: 'Paramount Admin',
        data: {'classId': classId},
      );

      // Notify enrolled students
      if (enrolledStudents != null && enrolledStudents.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          userIds: enrolledStudents,
          title: 'New Class Scheduled',
          message: '$subjectName class scheduled for ${startTime.day}/${startTime.month}/${startTime.year}',
          type: NotificationType.general,
          senderId: AuthService.currentUser?.uid ?? 'admin',
          senderName: 'Paramount Admin',
          data: {'classId': classId},
        );
      }

      return classId;
    } catch (e) {
      throw 'Failed to create class: $e';
    }
  }

  // ============== STATISTICS AND REPORTS ==============

  // Get system statistics
  static Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can view system statistics';
      }

      // Get user counts
      int totalUsers = await DatabaseService.getDocumentCount(FirebaseConfig.usersCollection);
      int totalStudents = (await AuthService.getUsersByRole(UserRole.student)).length;
      int totalTeachers = (await AuthService.getUsersByRole(UserRole.teacher)).length;
      int totalAdmins = (await AuthService.getUsersByRole(UserRole.admin)).length;

      // Get subject and class counts
      int totalSubjects = await DatabaseService.getDocumentCount(FirebaseConfig.subjectsCollection);
      int totalClasses = await DatabaseService.getDocumentCount(FirebaseConfig.classesCollection);

      // Get attendance statistics
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      
      QuerySnapshot monthlyAttendance = await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      int totalAttendanceRecords = monthlyAttendance.docs.length;
      int presentRecords = monthlyAttendance.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['isPresent'] == true)
          .length;
      
      double monthlyAttendanceRate = totalAttendanceRecords > 0 
          ? (presentRecords / totalAttendanceRecords) * 100 
          : 0.0;

      // Get assignment statistics
      int totalAssignments = await DatabaseService.getDocumentCount(FirebaseConfig.assignmentsCollection);

      return {
        'totalUsers': totalUsers,
        'totalStudents': totalStudents,
        'totalTeachers': totalTeachers,
        'totalAdmins': totalAdmins,
        'totalSubjects': totalSubjects,
        'totalClasses': totalClasses,
        'totalAssignments': totalAssignments,
        'monthlyAttendanceRecords': totalAttendanceRecords,
        'monthlyAttendanceRate': monthlyAttendanceRate,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      throw 'Failed to get system statistics: $e';
    }
  }

  // Generate user activity report
  static Future<Map<String, dynamic>> generateUserActivityReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can generate reports';
      }

      DateTime start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      DateTime end = endDate ?? DateTime.now();

      // Get active users (users who have attendance records in the period)
      QuerySnapshot attendanceSnapshot = await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      Set<String> activeStudents = {};
      Set<String> activeTeachers = {};

      for (QueryDocumentSnapshot doc in attendanceSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        activeStudents.add(data['studentId']);
        activeTeachers.add(data['teacherId']);
      }

      // Get assignment activity
      QuerySnapshot assignmentSnapshot = await _firestore
          .collection(FirebaseConfig.assignmentsCollection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      Map<String, int> teacherAssignments = {};
      for (QueryDocumentSnapshot doc in assignmentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String teacherId = data['teacherId'];
        teacherAssignments[teacherId] = (teacherAssignments[teacherId] ?? 0) + 1;
      }

      return {
        'reportPeriod': {
          'startDate': start,
          'endDate': end,
        },
        'activeStudents': activeStudents.length,
        'activeTeachers': activeTeachers.length,
        'totalAttendanceRecords': attendanceSnapshot.docs.length,
        'totalAssignmentsCreated': assignmentSnapshot.docs.length,
        'teacherAssignmentActivity': teacherAssignments,
        'activeStudentIds': activeStudents.toList(),
        'activeTeacherIds': activeTeachers.toList(),
      };
    } catch (e) {
      throw 'Failed to generate user activity report: $e';
    }
  }

  // ============== BULK OPERATIONS ==============

  // Bulk create users from CSV data
  static Future<Map<String, dynamic>> bulkCreateUsers(
      List<Map<String, dynamic>> userData) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can perform bulk operations';
      }

      List<String> successfulUsers = [];
      List<Map<String, dynamic>> failedUsers = [];

      for (Map<String, dynamic> user in userData) {
        try {
          UserModel? newUser = await AuthService.createUserWithEmailAndPassword(
            email: user['email'],
            password: user['password'] ?? 'paramount123',
            name: user['name'],
            phone: user['phone'] ?? '',
            role: UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == user['role'],
              orElse: () => UserRole.student,
            ),
            studentId: user['studentId'],
            teacherId: user['teacherId'],
            course: user['course'],
            semester: user['semester'] != null ? int.tryParse(user['semester'].toString()) : null,
          );

          if (newUser != null) {
            successfulUsers.add(newUser.uid);
          }
        } catch (e) {
          failedUsers.add({
            'userData': user,
            'error': e.toString(),
          });
        }
      }

      return {
        'successful': successfulUsers.length,
        'failed': failedUsers.length,
        'successfulUserIds': successfulUsers,
        'failedUsers': failedUsers,
      };
    } catch (e) {
      throw 'Failed to perform bulk user creation: $e';
    }
  }

  // ============== SYSTEM MAINTENANCE ==============

  // Clean up old data
  static Future<void> cleanupOldData({int daysOld = 365}) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can perform maintenance operations';
      }

      DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      // Clean up old attendance records
      QuerySnapshot oldAttendance = await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('date', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in oldAttendance.docs) {
        batch.delete(doc.reference);
      }

      if (oldAttendance.docs.isNotEmpty) {
        await batch.commit();
      }

      // Clean up old notifications
      QuerySnapshot oldNotifications = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      WriteBatch notificationBatch = _firestore.batch();
      for (QueryDocumentSnapshot doc in oldNotifications.docs) {
        notificationBatch.delete(doc.reference);
      }

      if (oldNotifications.docs.isNotEmpty) {
        await notificationBatch.commit();
      }
    } catch (e) {
      throw 'Failed to cleanup old data: $e';
    }
  }

  // Backup database
  static Future<Map<String, dynamic>> backupDatabase() async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can perform backup operations';
      }

      // This is a simplified backup - in real implementation,
      // you would use Firebase Admin SDK or Cloud Functions
      Map<String, dynamic> backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'collections': {
          'users': await _getAllDocuments(FirebaseConfig.usersCollection),
          'subjects': await _getAllDocuments(FirebaseConfig.subjectsCollection),
          'classes': await _getAllDocuments(FirebaseConfig.classesCollection),
          'attendance': await _getAllDocuments(FirebaseConfig.attendanceCollection),
          'assignments': await _getAllDocuments(FirebaseConfig.assignmentsCollection),
          'notifications': await _getAllDocuments(FirebaseConfig.notificationsCollection),
        },
      };

      return backup;
    } catch (e) {
      throw 'Failed to backup database: $e';
    }
  }

  // Helper method to get all documents from a collection
  static Future<List<Map<String, dynamic>>> _getAllDocuments(String collection) async {
    QuerySnapshot snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ============== NOTIFICATION MANAGEMENT ==============

  // Send system-wide announcement
  static Future<void> sendSystemAnnouncement({
    required String title,
    required String message,
    List<String>? targetRoles,
    String? imageUrl,
  }) async {
    try {
      // Verify admin permission
      bool isAdminUser = await AuthService.isAdmin();
      if (!isAdminUser) {
        throw 'Only admins can send system announcements';
      }

      await NotificationService.sendAnnouncement(
        title: title,
        message: message,
        senderId: AuthService.currentUser?.uid ?? 'admin',
        senderName: 'Paramount Admin',
        targetRoles: targetRoles,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw 'Failed to send system announcement: $e';
    }
  }
}
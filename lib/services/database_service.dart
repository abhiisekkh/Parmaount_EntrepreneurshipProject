import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../models/assignment_model.dart';
import '../models/notification_model.dart';
import '../config/firebase_config.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== USER OPERATIONS ==============

  // Create or update user
  static Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save user data. Please try again.';
    }
  }

  // Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data. Please try again.';
    }
  }

  // Get all users
  static Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get users. Please try again.';
    }
  }

  // Get users by role
  static Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('role', isEqualTo: role.toString().split('.').last)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get users by role. Please try again.';
    }
  }

  // ============== SUBJECT OPERATIONS ==============

  // Create subject
  static Future<String> createSubject(SubjectModel subject) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseConfig.subjectsCollection)
          .add(subject.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create subject. Please try again.';
    }
  }

  // Update subject
  static Future<void> updateSubject(SubjectModel subject) async {
    try {
      await _firestore
          .collection(FirebaseConfig.subjectsCollection)
          .doc(subject.id)
          .update(subject.toFirestore());
    } catch (e) {
      throw 'Failed to update subject. Please try again.';
    }
  }

  // Get all subjects
  static Future<List<SubjectModel>> getAllSubjects() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.subjectsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('subjectName')
          .get();

      return querySnapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get subjects. Please try again.';
    }
  }

  // Get subjects by teacher
  static Future<List<SubjectModel>> getSubjectsByTeacher(String teacherId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.subjectsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .orderBy('subjectName')
          .get();

      return querySnapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get subjects by teacher. Please try again.';
    }
  }

  // Get subjects by course and semester
  static Future<List<SubjectModel>> getSubjectsByCourseAndSemester(
      String course, String semester) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.subjectsCollection)
          .where('course', isEqualTo: course)
          .where('semester', isEqualTo: semester)
          .where('isActive', isEqualTo: true)
          .orderBy('subjectName')
          .get();

      return querySnapshot.docs
          .map((doc) => SubjectModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get subjects by course and semester. Please try again.';
    }
  }

  // ============== CLASS OPERATIONS ==============

  // Create class
  static Future<String> createClass(ClassModel classModel) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseConfig.classesCollection)
          .add(classModel.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create class. Please try again.';
    }
  }

  // Update class
  static Future<void> updateClass(ClassModel classModel) async {
    try {
      await _firestore
          .collection(FirebaseConfig.classesCollection)
          .doc(classModel.id)
          .update(classModel.toFirestore());
    } catch (e) {
      throw 'Failed to update class. Please try again.';
    }
  }

  // Get classes by teacher
  static Future<List<ClassModel>> getClassesByTeacher(String teacherId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.classesCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get classes by teacher. Please try again.';
    }
  }

  // Get classes for student
  static Future<List<ClassModel>> getClassesForStudent(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.classesCollection)
          .where('enrolledStudents', arrayContains: studentId)
          .where('isActive', isEqualTo: true)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get classes for student. Please try again.';
    }
  }

  // Get today's classes
  static Future<List<ClassModel>> getTodaysClasses() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.classesCollection)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('isActive', isEqualTo: true)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get today\'s classes. Please try again.';
    }
  }

  // ============== ATTENDANCE OPERATIONS ==============

  // Mark attendance
  static Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .add(attendance.toJson());
    } catch (e) {
      throw 'Failed to mark attendance. Please try again.';
    }
  }

  // Get attendance by student
  static Future<List<AttendanceModel>> getAttendanceByStudent(
      String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get attendance by student. Please try again.';
    }
  }

  // Get attendance by subject and student
  static Future<List<AttendanceModel>> getAttendanceBySubjectAndStudent(
      String studentId, String subject) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .where('subject', isEqualTo: subject)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get attendance by subject and student. Please try again.';
    }
  }

  // Get attendance statistics for student
  static Future<AttendanceStats> getAttendanceStats(
      String studentId, String subject) async {
    try {
      List<AttendanceModel> attendanceList = 
          await getAttendanceBySubjectAndStudent(studentId, subject);

      int totalClasses = attendanceList.length;
      int present = attendanceList.where((a) => a.isPresent).length;
      int absent = totalClasses - present;
      double percentage = totalClasses > 0 ? (present / totalClasses) * 100 : 0.0;

      return AttendanceStats(
        totalClasses: totalClasses,
        present: present,
        absent: absent,
        attendancePercentage: percentage,
      );
    } catch (e) {
      throw 'Failed to get attendance statistics. Please try again.';
    }
  }

  // ============== ASSIGNMENT OPERATIONS ==============

  // Create assignment
  static Future<String> createAssignment(AssignmentModel assignment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseConfig.assignmentsCollection)
          .add(assignment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create assignment. Please try again.';
    }
  }

  // Get assignments by teacher
  static Future<List<AssignmentModel>> getAssignmentsByTeacher(
      String teacherId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.assignmentsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .orderBy('dueDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AssignmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get assignments by teacher. Please try again.';
    }
  }

  // Get assignments for student
  static Future<List<AssignmentModel>> getAssignmentsForStudent(
      String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.assignmentsCollection)
          .where('assignedToStudents', arrayContains: studentId)
          .where('isActive', isEqualTo: true)
          .orderBy('dueDate')
          .get();

      return querySnapshot.docs
          .map((doc) => AssignmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get assignments for student. Please try again.';
    }
  }

  // ============== NOTIFICATION OPERATIONS ==============

  // Create notification
  static Future<String> createNotification(NotificationModel notification) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create notification. Please try again.';
    }
  }

  // Get notifications for user
  static Future<List<NotificationModel>> getNotificationsForUser(
      String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('recipientIds', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get notifications. Please try again.';
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Failed to mark notification as read. Please try again.';
    }
  }

  // ============== REAL-TIME STREAMS ==============

  // Get user stream
  static Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Get subjects stream
  static Stream<List<SubjectModel>> getSubjectsStream() {
    return _firestore
        .collection(FirebaseConfig.subjectsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('subjectName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubjectModel.fromFirestore(doc))
            .toList());
  }

  // Get classes stream for teacher
  static Stream<List<ClassModel>> getClassesStreamForTeacher(String teacherId) {
    return _firestore
        .collection(FirebaseConfig.classesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromFirestore(doc))
            .toList());
  }

  // Get notifications stream for user
  static Stream<List<NotificationModel>> getNotificationsStreamForUser(
      String userId) {
    return _firestore
        .collection(FirebaseConfig.notificationsCollection)
        .where('recipientIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // ============== HELPER METHODS ==============

  // Delete document
  static Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw 'Failed to delete document. Please try again.';
    }
  }

  // Get document count
  static Future<int> getDocumentCount(String collection) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw 'Failed to get document count. Please try again.';
    }
  }

  // Batch write operations
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (var operation in operations) {
        DocumentReference docRef = _firestore
            .collection(operation['collection'])
            .doc(operation['documentId']);

        switch (operation['type']) {
          case 'set':
            batch.set(docRef, operation['data']);
            break;
          case 'update':
            batch.update(docRef, operation['data']);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to perform batch operations. Please try again.';
    }
  }
}
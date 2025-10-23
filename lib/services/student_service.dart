import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get student data for current user
  static Future<Map<String, dynamic>?> getCurrentStudentData(String studentId) async {
    try {
      final doc = await _firestore.collection('users').doc(studentId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting current student data: $e');
      return null;
    }
  }

  // Get student attendance
  static Future<Map<String, dynamic>> getStudentAttendance(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();
      
      Map<String, dynamic> attendanceData = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final subject = data['subject'] ?? 'Unknown';
        
        if (!attendanceData.containsKey(subject)) {
          attendanceData[subject] = {
            'present': 0,
            'total': 0,
            'percentage': 0.0,
          };
        }
        
        attendanceData[subject]['total']++;
        if (data['status'] == 'present') {
          attendanceData[subject]['present']++;
        }
        
        attendanceData[subject]['percentage'] = 
            (attendanceData[subject]['present'] / attendanceData[subject]['total'] * 100).toDouble();
      }
      
      return attendanceData;
    } catch (e) {
      print('Error getting student attendance: $e');
      return {};
    }
  }

  // Get student grades
  static Future<List<Map<String, dynamic>>> getStudentGrades(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting student grades: $e');
      return [];
    }
  }

  // Get student assignments
  static Future<List<Map<String, dynamic>>> getStudentAssignments(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('assignments')
          .where('studentId', isEqualTo: studentId)
          .orderBy('dueDate', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'dueDate': (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      print('Error getting student assignments: $e');
      return [];
    }
  }

  // Get student notifications
  static Future<List<Map<String, dynamic>>> getStudentNotifications(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: studentId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      print('Error getting student notifications: $e');
      return [];
    }
  }

  // Get today's schedule
  static Future<List<Map<String, dynamic>>> getTodaySchedule(String studentId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final QuerySnapshot snapshot = await _firestore
          .collection('classes')
          .where('studentIds', arrayContains: studentId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('date', isLessThan: Timestamp.fromDate(todayEnd))
          .orderBy('date')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      print('Error getting today schedule: $e');
      return [];
    }
  }

  // Submit assignment
  static Future<bool> submitAssignment(String assignmentId, String submissionText, String? filePath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await _firestore.collection('submissions').add({
        'assignmentId': assignmentId,
        'studentId': user.uid,
        'submissionText': submissionText,
        'filePath': filePath,
        'submittedAt': Timestamp.now(),
        'status': 'submitted',
      });

      // Update assignment status
      await _firestore.collection('assignments').doc(assignmentId).update({
        'status': 'submitted',
        'submittedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      print('Error submitting assignment: $e');
      return false;
    }
  }

  // Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}

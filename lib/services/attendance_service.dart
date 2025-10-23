import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../config/firebase_config.dart';

class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== MARK ATTENDANCE ==============

  // Mark attendance for single student
  static Future<void> markAttendance({
    required String studentId,
    required String studentName,
    required String subject,
    required String teacherId,
    required String teacherName,
    required bool isPresent,
    String? remarks,
    DateTime? date,
  }) async {
    try {
      AttendanceModel attendance = AttendanceModel(
        id: '',
        studentId: studentId,
        studentName: studentName,
        subject: subject,
        teacherId: teacherId,
        teacherName: teacherName,
        date: date ?? DateTime.now(),
        isPresent: isPresent,
        remarks: remarks,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .add(attendance.toJson());
    } catch (e) {
      throw 'Failed to mark attendance: $e';
    }
  }

  // Mark attendance for multiple students
  static Future<void> markBulkAttendance({
    required List<String> studentIds,
    required Map<String, String> studentNames,
    required String subject,
    required String teacherId,
    required String teacherName,
    required Map<String, bool> attendanceData, // studentId -> isPresent
    Map<String, String>? remarks, // studentId -> remarks
    DateTime? date,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String studentId in studentIds) {
        AttendanceModel attendance = AttendanceModel(
          id: '',
          studentId: studentId,
          studentName: studentNames[studentId] ?? '',
          subject: subject,
          teacherId: teacherId,
          teacherName: teacherName,
          date: date ?? DateTime.now(),
          isPresent: attendanceData[studentId] ?? false,
          remarks: remarks?[studentId],
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        DocumentReference docRef = _firestore
            .collection(FirebaseConfig.attendanceCollection)
            .doc();
        
        batch.set(docRef, attendance.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to mark bulk attendance: $e';
    }
  }

  // ============== GET ATTENDANCE DATA ==============

  // Get attendance for a specific student
  static Future<List<AttendanceModel>> getStudentAttendance({
    required String studentId,
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('studentId', isEqualTo: studentId);

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      QuerySnapshot querySnapshot = await query.orderBy('date', descending: true).get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get student attendance: $e';
    }
  }

  // Get attendance statistics for a student
  static Future<AttendanceStats> getStudentAttendanceStats({
    required String studentId,
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<AttendanceModel> attendanceList = await getStudentAttendance(
        studentId: studentId,
        subject: subject,
        startDate: startDate,
        endDate: endDate,
      );

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
      throw 'Failed to get attendance statistics: $e';
    }
  }

  // Get attendance statistics for all subjects for a student
  static Future<Map<String, AttendanceStats>> getStudentAllSubjectsStats(
      String studentId) async {
    try {
      List<AttendanceModel> allAttendance = await getStudentAttendance(
        studentId: studentId,
      );

      Map<String, List<AttendanceModel>> subjectWiseAttendance = {};
      
      for (AttendanceModel attendance in allAttendance) {
        if (!subjectWiseAttendance.containsKey(attendance.subject)) {
          subjectWiseAttendance[attendance.subject] = [];
        }
        subjectWiseAttendance[attendance.subject]!.add(attendance);
      }

      Map<String, AttendanceStats> stats = {};
      
      for (String subject in subjectWiseAttendance.keys) {
        List<AttendanceModel> subjectAttendance = subjectWiseAttendance[subject]!;
        int totalClasses = subjectAttendance.length;
        int present = subjectAttendance.where((a) => a.isPresent).length;
        int absent = totalClasses - present;
        double percentage = totalClasses > 0 ? (present / totalClasses) * 100 : 0.0;

        stats[subject] = AttendanceStats(
          totalClasses: totalClasses,
          present: present,
          absent: absent,
          attendancePercentage: percentage,
        );
      }

      return stats;
    } catch (e) {
      throw 'Failed to get all subjects attendance statistics: $e';
    }
  }

  // Get today's attendance for teacher
  static Future<List<AttendanceModel>> getTodaysAttendanceForTeacher(
      String teacherId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get today\'s attendance: $e';
    }
  }

  // ============== REAL-TIME STREAMS ==============

  // Get attendance stream for student
  static Stream<List<AttendanceModel>> getStudentAttendanceStream(
      String studentId, String subject) {
    return _firestore
        .collection(FirebaseConfig.attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .where('subject', isEqualTo: subject)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // Get subject attendance stream for teacher
  static Stream<List<AttendanceModel>> getSubjectAttendanceStream({
    required String subject,
    required String teacherId,
  }) {
    return _firestore
        .collection(FirebaseConfig.attendanceCollection)
        .where('subject', isEqualTo: subject)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // ============== HELPER METHODS ==============

  // Delete attendance record
  static Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .doc(attendanceId)
          .delete();
    } catch (e) {
      throw 'Failed to delete attendance: $e';
    }
  }

  // Update attendance record
  static Future<void> updateAttendance(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection(FirebaseConfig.attendanceCollection)
          .doc(attendance.id)
          .update(attendance.copyWith(lastUpdated: DateTime.now()).toJson());
    } catch (e) {
      throw 'Failed to update attendance: $e';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'attendance';

  Future<void> initializeAttendanceCollection() async {
    try {
      final dummyDoc = _db.collection(_collection).doc('init');
      if (!(await dummyDoc.get()).exists) {
        await dummyDoc.set({
          'initialized': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error initializing attendance collection: $e');
      rethrow;
    }
  }

  Future<AttendanceModel> markAttendance({
    required String studentId,
    required String studentName,
    required String subject,
    required String teacherId,
    required String teacherName,
    required bool isPresent,
    String? remarks,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _db.collection(_collection).doc();
      
      final attendance = AttendanceModel(
        id: docRef.id,
        studentId: studentId,
        studentName: studentName,
        subject: subject,
        teacherId: teacherId,
        teacherName: teacherName,
        date: now,
        isPresent: isPresent,
        remarks: remarks,
        createdAt: now,
        lastUpdated: now,
      );

      await docRef.set(attendance.toJson());
      return attendance;
    } catch (e) {
      print('Error marking attendance: $e');
      throw Exception('Failed to mark attendance: $e');
    }
  }

  Stream<List<AttendanceModel>> getStudentAttendance(
      String studentId, String subject) {
    return _db
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .where('subject', isEqualTo: subject)
        .snapshots()
        .map((snapshot) {
          final attendances = snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList();
          attendances.sort((a, b) => b.date.compareTo(a.date));
          return attendances;
        });
  }

  Future<AttendanceStats> getStudentAttendanceStats(
      String studentId, String subject) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('subject', isEqualTo: subject)
          .get();

      final attendances = querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();

      return AttendanceStats.calculate(attendances);
    } catch (e) {
      print('Error getting attendance stats: $e');
      throw Exception('Failed to get attendance stats: $e');
    }
  }

  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _db.collection(_collection).doc(attendanceId).delete();
    } catch (e) {
      print('Error deleting attendance: $e');
      throw Exception('Failed to delete attendance: $e');
    }
  }
}

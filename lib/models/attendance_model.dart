import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String teacherId;
  final String teacherName;
  final DateTime date;
  final bool isPresent;
  final String? remarks;
  final DateTime createdAt;
  final DateTime lastUpdated;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.isPresent,
    this.remarks,
    required this.createdAt,
    required this.lastUpdated,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'subject': subject,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'date': date,
      'isPresent': isPresent,
      'remarks': remarks,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }

  // Create model from Firestore document
  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      subject: data['subject'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isPresent: data['isPresent'] ?? false,
      remarks: data['remarks'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Create a copy of the attendance with updated fields
  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? subject,
    String? teacherId,
    String? teacherName,
    DateTime? date,
    bool? isPresent,
    String? remarks,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      date: date ?? this.date,
      isPresent: isPresent ?? this.isPresent,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Class to store attendance statistics
class AttendanceStats {
  final int totalClasses;
  final int present;
  final int absent;
  final double attendancePercentage;

  AttendanceStats({
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.attendancePercentage,
  });

  factory AttendanceStats.calculate(List<AttendanceModel> attendances) {
    int present = attendances.where((a) => a.isPresent).length;
    int total = attendances.length;
    int absent = total - present;
    double percentage = total > 0 ? (present / total) * 100 : 0;

    return AttendanceStats(
      totalClasses: total,
      present: present,
      absent: absent,
      attendancePercentage: percentage,
    );
  }
}

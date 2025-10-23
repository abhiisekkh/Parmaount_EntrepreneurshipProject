import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String className;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final List<String> enrolledStudents;
  final String semester;
  final String course;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastUpdated;

  ClassModel({
    required this.id,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.enrolledStudents = const [],
    required this.semester,
    required this.course,
    this.isActive = true,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      className: data['className'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      room: data['room'] ?? '',
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
      semester: data['semester'] ?? '',
      course: data['course'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'className': className,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'room': room,
      'enrolledStudents': enrolledStudents,
      'semester': semester,
      'course': course,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  ClassModel copyWith({
    String? className,
    String? subjectId,
    String? subjectName,
    String? teacherId,
    String? teacherName,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    List<String>? enrolledStudents,
    String? semester,
    String? course,
    bool? isActive,
    DateTime? lastUpdated,
  }) {
    return ClassModel(
      id: id,
      className: className ?? this.className,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      semester: semester ?? this.semester,
      course: course ?? this.course,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  // Get duration of the class
  Duration get duration => endTime.difference(startTime);
  
  // Check if class is currently ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  // Check if class is upcoming (within next 2 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    return startTime.isAfter(now) && 
           startTime.difference(now).inHours <= 2;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String subjectCode;
  final String subjectName;
  final String description;
  final int credits;
  final String semester;
  final String course;
  final String teacherId;
  final String teacherName;
  final List<String> enrolledStudents;
  final Map<String, dynamic> schedule; // {day: time}
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isActive;

  SubjectModel({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.description,
    required this.credits,
    required this.semester,
    required this.course,
    required this.teacherId,
    required this.teacherName,
    this.enrolledStudents = const [],
    this.schedule = const {},
    required this.createdAt,
    required this.lastUpdated,
    this.isActive = true,
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      subjectCode: data['subjectCode'] ?? '',
      subjectName: data['subjectName'] ?? '',
      description: data['description'] ?? '',
      credits: data['credits'] ?? 0,
      semester: data['semester'] ?? '',
      course: data['course'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
      schedule: Map<String, dynamic>.from(data['schedule'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'description': description,
      'credits': credits,
      'semester': semester,
      'course': course,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'enrolledStudents': enrolledStudents,
      'schedule': schedule,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }

  SubjectModel copyWith({
    String? subjectCode,
    String? subjectName,
    String? description,
    int? credits,
    String? semester,
    String? course,
    String? teacherId,
    String? teacherName,
    List<String>? enrolledStudents,
    Map<String, dynamic>? schedule,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return SubjectModel(
      id: id,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      course: course ?? this.course,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }
}
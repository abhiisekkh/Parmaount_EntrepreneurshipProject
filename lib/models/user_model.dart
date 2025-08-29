import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  // Additional fields for students
  final String? studentId;
  final String? course;
  final int? semester;
  final Map<String, dynamic>? attendance;
  
  // Additional fields for teachers
  final String? teacherId;
  final List<String>? subjectsTaught;
  final List<String>? classesAssigned;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastUpdated,
    this.studentId,
    this.course,
    this.semester,
    this.attendance,
    this.teacherId,
    this.subjectsTaught,
    this.classesAssigned,
  });

  // Convert model to JSON for storing in Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'studentId': studentId,
      'course': course,
      'semester': semester,
      'attendance': attendance,
      'teacherId': teacherId,
      'subjectsTaught': subjectsTaught,
      'classesAssigned': classesAssigned,
    };
  }

  // Create model from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.student,
      ),
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      studentId: data['studentId'],
      course: data['course'],
      semester: data['semester'],
      attendance: data['attendance'],
      teacherId: data['teacherId'],
      subjectsTaught: List<String>.from(data['subjectsTaught'] ?? []),
      classesAssigned: List<String>.from(data['classesAssigned'] ?? []),
    );
  }

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? studentId,
    String? course,
    int? semester,
    Map<String, dynamic>? attendance,
    String? teacherId,
    List<String>? subjectsTaught,
    List<String>? classesAssigned,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      studentId: studentId ?? this.studentId,
      course: course ?? this.course,
      semester: semester ?? this.semester,
      attendance: attendance ?? this.attendance,
      teacherId: teacherId ?? this.teacherId,
      subjectsTaught: subjectsTaught ?? this.subjectsTaught,
      classesAssigned: classesAssigned ?? this.classesAssigned,
    );
  }
}

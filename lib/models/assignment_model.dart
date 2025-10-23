import 'package:cloud_firestore/cloud_firestore.dart';

enum AssignmentStatus { assigned, submitted, graded, overdue }

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final DateTime assignedDate;
  final DateTime dueDate;
  final int maxMarks;
  final List<String> attachmentUrls;
  final List<String> assignedToStudents;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isActive;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.assignedDate,
    required this.dueDate,
    required this.maxMarks,
    this.attachmentUrls = const [],
    this.assignedToStudents = const [],
    required this.createdAt,
    required this.lastUpdated,
    this.isActive = true,
  });

  factory AssignmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AssignmentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      assignedDate: (data['assignedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxMarks: data['maxMarks'] ?? 0,
      attachmentUrls: List<String>.from(data['attachmentUrls'] ?? []),
      assignedToStudents: List<String>.from(data['assignedToStudents'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'assignedDate': Timestamp.fromDate(assignedDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'maxMarks': maxMarks,
      'attachmentUrls': attachmentUrls,
      'assignedToStudents': assignedToStudents,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }

  // Check if assignment is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);
  
  // Get days remaining for submission
  int get daysRemaining {
    final difference = dueDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }
  
  // Get assignment status
  AssignmentStatus get status {
    if (isOverdue) return AssignmentStatus.overdue;
    return AssignmentStatus.assigned;
  }
}

class AssignmentSubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final List<String> attachmentUrls;
  final String? comments;
  final int? marksObtained;
  final String? teacherFeedback;
  final DateTime? gradedAt;
  final AssignmentStatus status;

  AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    this.attachmentUrls = const [],
    this.comments,
    this.marksObtained,
    this.teacherFeedback,
    this.gradedAt,
    this.status = AssignmentStatus.submitted,
  });

  factory AssignmentSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AssignmentSubmissionModel(
      id: doc.id,
      assignmentId: data['assignmentId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachmentUrls: List<String>.from(data['attachmentUrls'] ?? []),
      comments: data['comments'],
      marksObtained: data['marksObtained'],
      teacherFeedback: data['teacherFeedback'],
      gradedAt: (data['gradedAt'] as Timestamp?)?.toDate(),
      status: AssignmentStatus.values.firstWhere(
        (e) => e.toString() == 'AssignmentStatus.${data['status']}',
        orElse: () => AssignmentStatus.submitted,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'attachmentUrls': attachmentUrls,
      'comments': comments,
      'marksObtained': marksObtained,
      'teacherFeedback': teacherFeedback,
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
      'status': status.toString().split('.').last,
    };
  }
}
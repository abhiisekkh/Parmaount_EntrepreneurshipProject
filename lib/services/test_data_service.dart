// Mock data service for testing without Firebase

class TestDataService {
  static final TestDataService _instance = TestDataService._internal();
  factory TestDataService() => _instance;
  TestDataService._internal();

  // Mock students data
  final List<Map<String, dynamic>> _students = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@test.com',
      'course': 'Computer Science',
      'semester': 3,
      'attendance': {
        'Physics': {'total': 20, 'present': 18},
        'Chemistry': {'total': 18, 'present': 15},
        'Mathematics': {'total': 22, 'present': 20},
      },
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@test.com',
      'course': 'Computer Science',
      'semester': 3,
      'attendance': {
        'Physics': {'total': 20, 'present': 16},
        'Chemistry': {'total': 18, 'present': 17},
        'Mathematics': {'total': 22, 'present': 19},
      },
    },
  ];

  // Mock faculty data
  final List<Map<String, dynamic>> _faculty = [
    {
      'id': '101',
      'name': 'Dr. Alan Turing',
      'email': 'turing@test.com',
      'department': 'Computer Science',
      'subjects': ['Algorithms', 'Discrete Mathematics'],
    },
    {
      'id': '102',
      'name': 'Dr. Grace Hopper',
      'email': 'hopper@test.com',
      'department': 'Computer Science',
      'subjects': ['Programming', 'Compiler Design'],
    },
  ];

  // Mock courses data
  final List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS101',
      'name': 'Introduction to Programming',
      'semester': 1,
      'credits': 4,
    },
    {
      'code': 'CS102',
      'name': 'Data Structures',
      'semester': 2,
      'credits': 4,
    },
  ];

  // Get all students
  List<Map<String, dynamic>> getAllStudents() => _students;

  // Get all faculty
  List<Map<String, dynamic>> getAllFaculty() => _faculty;

  // Get all courses
  List<Map<String, dynamic>> getAllCourses() => _courses;

  // Add a new student
  void addStudent(Map<String, dynamic> student) {
    _students.add(student);
  }

  // Add a new faculty member
  void addFaculty(Map<String, dynamic> faculty) {
    _faculty.add(faculty);
  }

  // Update student attendance
  // Attendance records stored with date and subject
  final List<Map<String, dynamic>> _attendanceRecords = [];

  void markAttendance(Map<String, dynamic> record) {
    _attendanceRecords.add({
      ...record,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get attendance by subject and date
  List<Map<String, dynamic>> getAttendanceBySubject(String subject, String date) {
    return _attendanceRecords.where((record) => 
      record['subject'] == subject && record['date'] == date
    ).toList();
  }

  // Get student's attendance by subject
  Map<String, int> getStudentAttendanceBySubject(String studentId) {
    final Map<String, int> subjectAttendance = {};
    final studentRecords = _attendanceRecords.where((record) => 
      record['studentId'] == studentId && record['status'] == 'Present'
    );

    for (var record in studentRecords) {
      final subject = record['subject'] as String;
      subjectAttendance[subject] = (subjectAttendance[subject] ?? 0) + 1;
    }

    return subjectAttendance;
  }

  // Get student by ID
  Map<String, dynamic>? getStudentById(String id) {
    try {
      return _students.firstWhere((student) => student['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get faculty by ID
  Map<String, dynamic>? getFacultyById(String id) {
    try {
      return _faculty.firstWhere((faculty) => faculty['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get course by code
  Map<String, dynamic>? getCourseByCode(String code) {
    try {
      return _courses.firstWhere((course) => course['code'] == code);
    } catch (e) {
      return null;
    }
  }
}

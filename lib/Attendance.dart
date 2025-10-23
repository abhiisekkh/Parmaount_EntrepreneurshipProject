import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/attendance_service.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final UserService _userService = UserService();
  
  List<UserModel> _students = [];
  Map<String, String> _attendanceStatus = {};
  UserModel? _currentTeacher;
  
  String _selectedCourse = '';
  List<String> _courses = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current teacher
      final User? currentUser = FirebaseAuth.instance.currentUser;
      List<UserModel> studentsSnapshot = [];
      
      if (currentUser != null) {
        try {
          _currentTeacher = await _userService.getUserData(currentUser.uid);
        } catch (e) {
          print('Failed to get teacher data: $e');
          // Create a demo teacher for testing
          _currentTeacher = UserModel(
            uid: currentUser.uid,
            email: currentUser.email ?? 'demo@teacher.com',
            name: 'Demo Teacher',
            role: UserRole.teacher,
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
        }
        
        if (_currentTeacher != null && _currentTeacher!.role == UserRole.teacher) {
          // Get courses taught by this teacher
          _courses = _currentTeacher!.subjectsTaught ?? [];
          
          // If no subjects assigned, provide default subjects
          if (_courses.isEmpty) {
            _courses = ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science'];
          }
          
          if (_courses.isNotEmpty) {
            setState(() {
              _selectedCourse = _courses[0];
            });
          }

          // Try to get students from Firestore
          try {
            final streamData = await _userService.getUsersByRole(UserRole.student).first.timeout(
              const Duration(seconds: 5),
            );
            studentsSnapshot = streamData;
            print('Loaded ${studentsSnapshot.length} students from Firebase');
          } catch (e) {
            print('Failed to load students from Firebase: $e');
          }
        }
      }

      // If no user signed in or no students found, use demo data
      if (studentsSnapshot.isEmpty) {
        print('No students found in Firebase, loading demo students...');
        studentsSnapshot = _userService.getDemoStudents();
        print('Demo students loaded: ${studentsSnapshot.length} students');
        for (var student in studentsSnapshot) {
          print('Demo student: ${student.name} (${student.studentId})');
        }
        
        // Also create a demo teacher if none exists
        if (_currentTeacher == null) {
          print('Creating demo teacher...');
          _currentTeacher = UserModel(
            uid: 'demo_teacher',
            email: 'demo@teacher.com',
            name: 'Demo Teacher',
            role: UserRole.teacher,
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
          
          _courses = ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science'];
          if (_courses.isNotEmpty) {
            setState(() {
              _selectedCourse = _courses[0];
            });
          }
          print('Demo teacher created: ${_currentTeacher!.name}');
        }
      } else {
        print('Found ${studentsSnapshot.length} students from Firebase');
      }

      if (mounted) {
        setState(() {
          _students = studentsSnapshot;
          // Initialize all students as "Not Marked"
          _attendanceStatus = {
            for (var student in _students) student.uid: 'Not Marked'
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentTeacher == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, String>> submittedStudents = [];
      
      for (var student in _students) {
        final status = _attendanceStatus[student.uid];
        if (status == null || status == 'Not Marked') continue;

        await AttendanceService.markAttendance(
          studentId: student.uid,
          studentName: student.name,
          subject: _selectedCourse,
          teacherId: _currentTeacher!.uid,
          teacherName: _currentTeacher!.name,
          isPresent: status.toLowerCase() == 'present',
          remarks: status == 'Late' ? 'Student was late' : null,
        );
        
        submittedStudents.add({
          'name': student.name,
          'status': status,
        });
      }

      if (mounted) {
        if (submittedStudents.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No attendance marked! Please mark attendance for students first.'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          String studentList = submittedStudents
              .map((s) => '${s['name']}: ${s['status']}')
              .join(', ');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance submitted for ${submittedStudents.length} students:\n$studentList'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting attendance: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mark Attendance'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFFB993FF), Color(0xFFF5F6FA)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildCourseAndDateSelector(context),
                  const Divider(height: 1, thickness: 1),
                  _buildAttendanceSummary(),
                  Expanded(
                    child: _courses.isEmpty
                        ? const Center(
                            child: Text('No courses assigned to you.'),
                          )
                        : _students.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.group_off, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No students found',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    Text(
                                      'Check your internet connection and try again',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: _students.length,
                                itemBuilder: (context, index) {
                                  final student = _students[index];
                                  return _buildStudentAttendanceCard(context, student);
                                },
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitAttendance,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Submit Attendance'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Oswald',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    int totalStudents = _students.length;
    int markedStudents = _attendanceStatus.values
        .where((status) => status != 'Not Marked')
        .length;
    int presentCount = _attendanceStatus.values
        .where((status) => status == 'Present')
        .length;
    int absentCount = _attendanceStatus.values
        .where((status) => status == 'Absent')
        .length;
    int lateCount = _attendanceStatus.values
        .where((status) => status == 'Late')
        .length;
    int notMarkedCount = totalStudents - markedStudents;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Attendance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('Total', totalStudents.toString(), Colors.blue),
              const SizedBox(width: 8),
              _buildSummaryItem('Present', presentCount.toString(), Colors.green),
              const SizedBox(width: 8),
              _buildSummaryItem('Absent', absentCount.toString(), Colors.red),
              const SizedBox(width: 8),
              _buildSummaryItem('Late', lateCount.toString(), Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryItem('Marked', markedStudents.toString(), Colors.purple),
              const SizedBox(width: 8),
              _buildSummaryItem('Pending', notMarkedCount.toString(), Colors.grey),
            ],
          ),
          if (totalStudents > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress: ${((markedStudents / totalStudents) * 100).toStringAsFixed(1)}% Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: markedStudents / totalStudents,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                markedStudents == totalStudents ? Colors.green : Colors.blue.shade600,
              ),
              minHeight: 6,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    IconData icon;
    switch (label.toLowerCase()) {
      case 'total':
        icon = Icons.group;
        break;
      case 'present':
        icon = Icons.check_circle;
        break;
      case 'absent':
        icon = Icons.cancel;
        break;
      case 'late':
        icon = Icons.access_time;
        break;
      case 'marked':
        icon = Icons.edit;
        break;
      default:
        icon = Icons.info;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseAndDateSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Course Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCourse,
            decoration: const InputDecoration(
              labelText: 'Select Course',
              prefixIcon: Icon(Icons.book),
            ),
            items: _courses.map((String course) {
              return DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCourse = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 15),

          // Date Picker
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Select Date',
                prefixIcon: Icon(Icons.calendar_month),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedDate.toLocal()}'.split(' ')[0],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildStudentAttendanceCard(BuildContext context, UserModel student) {
    final status = _attendanceStatus[student.uid] ?? 'Not Marked';
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green.shade100;
        statusIcon = Icons.check_circle;
        break;
      case 'absent':
        statusColor = Colors.red.shade100;
        statusIcon = Icons.cancel;
        break;
      case 'late':
        statusColor = Colors.orange.shade100;
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = Colors.grey.shade100;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: status == 'Not Marked' ? Colors.grey.shade300 : _getStatusColor(status),
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [statusColor, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _getStatusColor(status).withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: _getStatusColor(status),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${student.studentId ?? 'No ID'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (student.course != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Course: ${student.course}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  statusIcon,
                  color: _getStatusColor(status),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: status,
                    underline: const SizedBox(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: ['Not Marked', 'Present', 'Absent', 'Late']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _attendanceStatus[student.uid] = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
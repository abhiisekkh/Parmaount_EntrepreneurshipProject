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
  final AttendanceService _attendanceService = AttendanceService();
  
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
      if (currentUser != null) {
        _currentTeacher = await _userService.getUserData(currentUser.uid);
        
        if (_currentTeacher != null && _currentTeacher!.role == UserRole.teacher) {
          // Get courses taught by this teacher
          _courses = _currentTeacher!.subjectsTaught ?? [];
          if (_courses.isNotEmpty) {
            setState(() {
              _selectedCourse = _courses[0];
            });
          }

          // Get students from Firestore
          final studentsSnapshot = await _userService.getUsersByRole(UserRole.student).first;
          
          setState(() {
            _students = studentsSnapshot;
            // Initialize all students as "Not Marked"
            _attendanceStatus = {
              for (var student in _students) student.uid: 'Not Marked'
            };
          });
        }
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
      for (var student in _students) {
        final status = _attendanceStatus[student.uid];
        if (status == null || status == 'Not Marked') continue;

        await _attendanceService.markAttendance(
          studentId: student.uid,
          studentName: student.name,
          subject: _selectedCourse,
          teacherId: _currentTeacher!.uid,
          teacherName: _currentTeacher!.name,
          isPresent: status.toLowerCase() == 'present',
          remarks: status == 'Late' ? 'Student was late' : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance submitted successfully!')),
        );
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
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Course and Date selection
                _buildCourseAndDateSelector(context),
                const Divider(height: 1, thickness: 1),
                
                // Student list for attendance marking
                Expanded(
                  child: _courses.isEmpty
                      ? const Center(
                          child: Text('No courses assigned to you.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return _buildStudentAttendanceCard(
                              context,
                              student,
                            );
                          },
                        ),
                ),

                // Submit button
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
                    ),
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
            value: _selectedCourse,
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
    
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green.shade100;
        break;
      case 'absent':
        statusColor = Colors.red.shade100;
        break;
      case 'late':
        statusColor = Colors.orange.shade100;
        break;
      default:
        statusColor = Colors.grey.shade100;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: statusColor,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(student.name),
        subtitle: Text(student.studentId ?? 'No ID'),
        trailing: DropdownButton<String>(
          value: status,
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
          style: TextStyle(
            color: _getStatusColor(status),
            fontWeight: FontWeight.bold,
          ),
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
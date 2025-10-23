import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceTestPage extends StatefulWidget {
  const AttendanceTestPage({super.key});

  @override
  State<AttendanceTestPage> createState() => _AttendanceTestPageState();
}

class _AttendanceTestPageState extends State<AttendanceTestPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  bool _isPresent = true;
  @override
  void initState() {
    super.initState();
    // Pre-fill with test data
    _studentIdController.text = 'TEST001';
    _studentNameController.text = 'Test Student';
    _subjectController.text = 'Mathematics';
    
    // Initialize the attendance collection
    _initializeAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance System Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mark Attendance',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _studentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Status:'),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('Present'),
                          selected: _isPresent,
                          onSelected: (bool selected) {
                            setState(() => _isPresent = selected);
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Absent'),
                          selected: !_isPresent,
                          onSelected: (bool selected) {
                            setState(() => _isPresent = !selected);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _markAttendance,
                      child: const Text('Mark Attendance'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attendance List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Attendance Records',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    FutureBuilder<List<AttendanceModel>>(
                      future: AttendanceService.getStudentAttendance(
                          studentId: _studentIdController.text, 
                          subject: _subjectController.text),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final attendances = snapshot.data!;
                        if (attendances.isEmpty) {
                          return const Text('No attendance records found');
                        }
                        return Column(
                          children: attendances.map((attendance) {
                            return ListTile(
                              leading: Icon(
                                attendance.isPresent
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: attendance.isPresent
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(attendance.studentName),
                              subtitle: Text(
                                  '${attendance.subject} - ${attendance.date.toString().split(' ')[0]}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _deleteAttendance(attendance.id),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance Statistics',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    FutureBuilder<AttendanceStats>(
                      future: AttendanceService.getStudentAttendanceStats(
                          studentId: _studentIdController.text, 
                          subject: _subjectController.text),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final stats = snapshot.data!;
                        return Column(
                          children: [
                            _buildStatTile('Total Classes',
                                stats.totalClasses.toString()),
                            _buildStatTile(
                                'Present', stats.present.toString()),
                            _buildStatTile('Absent', stats.absent.toString()),
                            _buildStatTile('Attendance',
                                '${stats.attendancePercentage.toStringAsFixed(1)}%'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _markAttendance() async {
    if (_studentIdController.text.isEmpty ||
        _studentNameController.text.isEmpty ||
        _subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await AttendanceService.markAttendance(
        studentId: _studentIdController.text,
        studentName: _studentNameController.text,
        subject: _subjectController.text,
        teacherId: 'TEST_TEACHER',
        teacherName: 'Test Teacher',
        isPresent: _isPresent,
        remarks: 'Test attendance',
      );

      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance marked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAttendance(String attendanceId) async {
    try {
      await AttendanceService.deleteAttendance(attendanceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance record deleted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeAttendance() async {
    try {
      // Attendance system is initialized automatically with Firebase
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance system initialized successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing attendance system: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}

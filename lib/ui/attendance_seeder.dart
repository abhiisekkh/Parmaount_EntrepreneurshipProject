import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AttendanceSeeder extends StatefulWidget {
  const AttendanceSeeder({super.key});

  @override
  State<AttendanceSeeder> createState() => _AttendanceSeederState();
}

class _AttendanceSeederState extends State<AttendanceSeeder> {
  final UserService _userService = UserService();
  bool _isSeeding = false;
  String _seedingStatus = '';
  final List<String> _seedingLogs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Attendance Collection'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildActionCard(),
            const SizedBox(height: 24),
            if (_seedingLogs.isNotEmpty) _buildLogsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restore,
                  color: Colors.green.shade700,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restore Attendance Data',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recreate the attendance collection with sample data',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'What this will do:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoPoint('✅ Create sample attendance records for demo students'),
                  _buildInfoPoint('✅ Generate data for the last 7 days'),
                  _buildInfoPoint('✅ Include Present, Absent, and Late statuses'),
                  _buildInfoPoint('✅ Show realistic attendance patterns'),
                  _buildInfoPoint('✅ Restore the "attendance" collection in Firestore'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_isSeeding) ...[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                _seedingStatus,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Icon(
                Icons.cloud_upload,
                size: 48,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ready to Restore Attendance Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This will create sample attendance records for the past week',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _seedAttendanceData,
                  icon: const Icon(Icons.restore, size: 24),
                  label: const Text(
                    'Restore Attendance Collection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 300,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.terminal, color: Colors.grey.shade700),
                const SizedBox(width: 12),
                Text(
                  'Seeding Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _seedingLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _seedingLogs[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seedAttendanceData() async {
    setState(() {
      _isSeeding = true;
      _seedingStatus = 'Initializing...';
      _seedingLogs.clear();
    });

    try {
      _addLog('🚀 Starting attendance data restoration...');
      
      // Get demo students
      final demoStudents = _userService.getDemoStudents();
      _addLog('📚 Loaded ${demoStudents.length} demo students');

      // Demo teacher data
      final demoTeacher = UserModel(
        uid: 'demo_teacher',
        email: 'demo@teacher.com',
        name: 'Demo Teacher',
        role: UserRole.teacher,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final subjects = ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science'];
      final statuses = ['Present', 'Absent', 'Late'];
      final statusWeights = [0.7, 0.2, 0.1]; // 70% present, 20% absent, 10% late

      int totalRecords = 0;

      // Generate attendance for the last 7 days
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = DateTime.now().subtract(Duration(days: dayOffset));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        _updateStatus('Creating records for $dateStr...');
        _addLog('📅 Processing $dateStr');

        for (final subject in subjects.take(2)) { // Only 2 subjects per day
          _addLog('  📖 Subject: $subject');
          
          for (final student in demoStudents) {
            // Generate realistic attendance (mostly present)
            final random = DateTime.now().millisecond + student.uid.hashCode + dayOffset;
            final statusIndex = _getWeightedRandomIndex(statusWeights, random);
            final status = statuses[statusIndex];
            
            try {
              await AttendanceService.markAttendance(
                studentId: student.uid,
                studentName: student.name,
                subject: subject,
                teacherId: demoTeacher.uid,
                teacherName: demoTeacher.name,
                isPresent: status == 'Present',
                remarks: status == 'Late' ? 'Student was late' : null,
                date: date,
              );
              
              totalRecords++;
              _addLog('    ✅ ${student.name}: $status');
              
              // Add small delay to prevent overwhelming Firestore
              await Future.delayed(const Duration(milliseconds: 100));
              
            } catch (e) {
              _addLog('    ❌ Error for ${student.name}: $e');
            }
          }
        }
      }

      _addLog('🎉 Completed! Created $totalRecords attendance records');
      _updateStatus('Successfully restored attendance collection!');
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                const Text('Success!'),
              ],
            ),
            content: Text(
              'Successfully created $totalRecords attendance records in your Firestore database.\n\n'
              'You can now view them in:\n'
              '• Firebase Console\n'
              '• Your app\'s Database Viewer\n'
              '• Attendance reports',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Great!'),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      _addLog('❌ Error: $e');
      _updateStatus('Failed to restore attendance data');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  int _getWeightedRandomIndex(List<double> weights, int seed) {
    final random = (seed % 100) / 100.0; // Convert to 0-1 range
    double cumulative = 0.0;
    
    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (random <= cumulative) {
        return i;
      }
    }
    
    return weights.length - 1;
  }

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _seedingLogs.add('${DateTime.now().toString().substring(11, 19)} $message');
      });
    }
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _seedingStatus = status;
      });
    }
  }
}
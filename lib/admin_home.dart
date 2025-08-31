import 'package:flutter/material.dart';
import 'services/test_data_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TestDataService _testDataService = TestDataService();
  Map<String, dynamic> _dashboardStats = {
    'totalStudents': 0,
    'totalTeachers': 0,
    'totalCourses': 0,
    'attendanceToday': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    // Get data from TestDataService
    setState(() {
      _dashboardStats = {
        'totalStudents': _testDataService.getAllStudents().length,
        'totalTeachers': _testDataService.getAllFaculty().length,
        'totalCourses': _testDataService.getAllCourses().length,
        'attendanceToday': _testDataService.getAllStudents().fold<int>(
          0,
          (sum, student) {
            final attendance = student['attendance'] as Map<dynamic, dynamic>?;
            return sum + (attendance?.length ?? 0);
          },
        ),
      };
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          // Navigate to auth page and clear navigation history
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/auth',
                            (route) => false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out successfully')),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Students',
                    _dashboardStats['totalStudents'].toString(),
                    Icons.school,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Total Teachers',
                    _dashboardStats['totalTeachers'].toString(),
                    Icons.person,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Total Courses',
                    _dashboardStats['totalCourses'].toString(),
                    Icons.book,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Today\'s Attendance',
                    _dashboardStats['attendanceToday'].toString(),
                    Icons.checklist,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                'Manage Students',
                'Add, edit, or remove students',
                Icons.group,
                () => Navigator.pushNamed(context, '/admin/students'),
              ),
              const SizedBox(height: 8),
              _buildActionCard(
                'Manage Faculty',
                'Add, edit, or remove teachers',
                Icons.person_add,
                () => Navigator.pushNamed(context, '/admin/faculty'),
              ),
              const SizedBox(height: 8),
              _buildActionCard(
                'Course Management',
                'Manage courses and assignments',
                Icons.book,
                () => Navigator.pushNamed(context, '/admin/courses'),
              ),
              const SizedBox(height: 8),
              _buildActionCard(
                'Attendance Reports',
                'View and export attendance records',
                Icons.assessment,
                () => Navigator.pushNamed(context, '/admin/attendance'),
              ),
              const SizedBox(height: 8),
              _buildActionCard(
                'System Settings',
                'Configure system preferences',
                Icons.settings,
                () => Navigator.pushNamed(context, '/admin/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

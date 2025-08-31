import 'package:flutter/material.dart';
import 'services/user_service.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  // Dummy teacher data
  final String teacherName = 'Mr. Sunil Sharma';
  final String teacherId = 'TCH7890';
  final String department = 'Computer Science';
  final String profileImageUrl = 'assets/images/sunil.jpg'; // Example image

  // Dummy courses data
  final List<Map<String, String>> courses = const [
    {'name': 'Data Structures', 'code': 'CS301', 'students': '60'},
    {'name': 'Algorithms', 'code': 'CS302', 'students': '55'},
    {'name': 'Operating Systems', 'code': 'CS401', 'students': '40'},
    {'name': 'Database Management', 'code': 'CS402', 'students': '45'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showMessage(context, 'No new notifications for teachers.');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await UserService().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/auth');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: _buildTeacherDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Profile Header
            _buildProfileHeader(context),
            const SizedBox(height: 25),

            // Teaching Courses Section
            Text(
              'My Teaching Courses',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 15),
            // Courses ko ListView.builder se dynamically dikhaya
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _buildCourseCard(
                  context,
                  courseName: course['name']!,
                  courseCode: course['code']!,
                  studentCount: course['students']!,
                  onTap: () {
                    _showMessage(context, 'Managing course: ${course['name']}');
                    // Navigator.of(context).pushNamed('/course_details', arguments: course);
                  },
                );
              },
            ),
            const SizedBox(height: 25),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.person_add_alt_1,
                  label: 'Add Student',
                  onTap: () => Navigator.of(context).pushNamed('/add_student'),
                  color: Colors.purple.shade100,
                  iconColor: Colors.purple.shade700,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.edit_calendar,
                  label: 'Mark Attendance',
                  onTap: () => Navigator.of(context).pushNamed('/attendance'),
                  color: Colors.red.shade100,
                  iconColor: Colors.red.shade700,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.upload_file,
                  label: 'Upload Grades',
                  onTap: () {
                    _showMessage(context, 'Grade upload feature is in development.');
                  },
                  color: Colors.lightBlue.shade100,
                  iconColor: Colors.lightBlue.shade700,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.announcement,
                  label: 'Send Announcement',
                  onTap: () {
                    _showMessage(context, 'Announcement feature coming soon!');
                  },
                  color: Colors.amber.shade100,
                  iconColor: Colors.amber.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Teacher profile header widget
  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      color: Colors.deepPurple.shade50,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple.shade200,
              backgroundImage: AssetImage(profileImageUrl), // Aapki profile image
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback if image fails to load
                debugPrint('Error loading image: $exception');
              },
              child: profileImageUrl.isEmpty // Agar image na ho toh fallback icon
                  ? Icon(Icons.person, size: 50, color: Colors.deepPurple.shade700)
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacherName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade900,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'ID: $teacherId',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'Oswald'),
                  ),
                  Text(
                    'Department: $department',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'Oswald'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Course card for teachers
  Widget _buildCourseCard(
      BuildContext context, {
        required String courseName,
        required String courseCode,
        required String studentCount,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.indigo.shade50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.class_, size: 40, color: Colors.indigo.shade700),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                        fontFamily: 'Oswald',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Code: $courseCode',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontFamily: 'Oswald'),
                    ),
                    Text(
                      'Students: $studentCount',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontFamily: 'Oswald'),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Action button for quick access
  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color color,
        required Color iconColor,
      }) {
    return Card(
      color: color,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple.shade900,
                fontFamily: 'Oswald',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Teacher specific navigation drawer
  Widget _buildTeacherDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(teacherName, style: const TextStyle(fontFamily: 'Oswald', fontWeight: FontWeight.bold)),
            accountEmail: Text(department, style: const TextStyle(fontFamily: 'Oswald')),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(profileImageUrl), // Teacher profile image
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading image in drawer: $exception');
              },
              child: profileImageUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Dashboard',
            onTap: () => Navigator.popAndPushNamed(context, '/teacher_home'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.edit_calendar,
            title: 'Mark Attendance',
            onTap: () => Navigator.popAndPushNamed(context, '/attendance'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_add_alt_1,
            title: 'Add Student',
            onTap: () => Navigator.popAndPushNamed(context, '/add_student'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.upload_file,
            title: 'Upload Grades',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Upload grades for your courses.');
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Teacher settings coming soon.');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/home');
            },
            isImportant: true,
          ),
        ],
      ),
    );
  }

  // Drawer item widget
  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, bool isImportant = false}) {
    return ListTile(
      leading: Icon(icon, color: isImportant ? Theme.of(context).colorScheme.secondary : Colors.deepPurple.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
          color: isImportant ? Theme.of(context).colorScheme.secondary : Colors.deepPurple.shade900,
          fontFamily: 'Oswald',
        ),
      ),
      onTap: onTap,
    );
  }

  // Generic message dialog
  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Information', style: TextStyle(fontFamily: 'Oswald')),
          content: Text(message, style: const TextStyle(fontFamily: 'Oswald')),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(dialogContext).primaryColor, fontFamily: 'Oswald')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

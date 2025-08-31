import 'package:flutter/material.dart';
import 'services/user_service.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  // Dummy student data
  final String studentName = 'Aaryan Upadhyay';
  final String studentId = 'STD12345';
  final String course = 'B.Tech Computer Science';
  final String currentSemester = '5th Semester';
  final String profileImageUrl = 'assets/images/girl.png'; // Example image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showMessage(context, 'No new notifications.');
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
      drawer: _buildStudentDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Header
            _buildProfileHeader(context),
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
              physics:
                  const NeverScrollableScrollPhysics(), // Scrollable GridView ke andar
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: 'View Attendance',
                  onTap: () =>
                      Navigator.of(context).pushNamed('/student_attendance'),
                  color: Colors.teal.shade100,
                  iconColor: Colors.teal.shade700,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.grade,
                  label: 'Check Grades',
                  onTap: () {
                    _showMessage(
                        context,
                        'Grades for '
                        '$currentSemester'
                        ' are available soon!');
                  },
                  color: Colors.orange.shade100,
                  iconColor: Colors.orange.shade700,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.assignment,
                  label: 'Assignments',
                  onTap: () {
                    _showMessage(context, 'No pending assignments.');
                  },
                  color: Colors.blue.shade100,
                  iconColor: Colors.blue.shade700,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.payment,
                  label: 'Fee Status',
                  onTap: () {
                    _showMessage(
                        context, 'Your fee for this semester is paid.');
                  },
                  color: Colors.green.shade100,
                  iconColor: Colors.green.shade700,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Upcoming Events/Announcements
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                    fontFamily: 'Oswald',
                  ),
            ),
            const SizedBox(height: 15),
            _buildEventCard(
              context,
              title: 'Mid-Term Exams',
              date: 'October 25 - Nov 5',
              description:
                  'Prepare well for your upcoming mid-term examinations.',
            ),
            _buildEventCard(
              context,
              title: 'Annual Sports Day',
              date: 'December 12',
              description: 'Join us for a day of fun and sports activities.',
            ),
          ],
        ),
      ),
    );
  }

  // Student profile header widget
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
              backgroundImage:
                  AssetImage(profileImageUrl), // Aapki profile image
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback if image fails to load
                debugPrint('Error loading image: $exception');
              },
              child:
                  profileImageUrl.isEmpty // Agar image na ho toh fallback icon
                      ? Icon(Icons.person,
                          size: 50, color: Colors.deepPurple.shade700)
                      : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade900,
                          fontFamily: 'Oswald',
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'ID: $studentId',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontFamily: 'Oswald'),
                  ),
                  Text(
                    'Course: $course',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontFamily: 'Oswald'),
                  ),
                  Text(
                    'Semester: $currentSemester',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontFamily: 'Oswald'),
                  ),
                ],
              ),
            ),
          ],
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

  // Event card widget
  Widget _buildEventCard(BuildContext context,
      {required String title,
      required String date,
      required String description}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                    fontFamily: 'Oswald',
                  ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.event, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 5),
                Text(
                  date,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'Oswald'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  fontFamily: 'Oswald'),
            ),
          ],
        ),
      ),
    );
  }

  // Student specific navigation drawer
  Widget _buildStudentDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(studentName,
                style: const TextStyle(
                    fontFamily: 'Oswald', fontWeight: FontWeight.bold)),
            accountEmail:
                Text(studentId, style: const TextStyle(fontFamily: 'Oswald')),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  AssetImage(profileImageUrl), // Student profile image
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading image in drawer: $exception');
              },
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Dashboard',
            onTap: () => Navigator.popAndPushNamed(context, '/student_home'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today,
            title: 'My Attendance',
            onTap: () =>
                Navigator.popAndPushNamed(context, '/student_attendance'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.grade,
            title: 'My Grades',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Check your latest grades here.');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.book,
            title: 'My Courses',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'View details of your enrolled courses.');
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Settings options are coming soon.');
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
  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isImportant = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isImportant
              ? Theme.of(context).colorScheme.secondary
              : Colors.deepPurple.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
          color: isImportant
              ? Theme.of(context).colorScheme.secondary
              : Colors.deepPurple.shade900,
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
          title:
              const Text('Information', style: TextStyle(fontFamily: 'Oswald')),
          content: Text(message, style: const TextStyle(fontFamily: 'Oswald')),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: TextStyle(
                      color: Theme.of(dialogContext).primaryColor,
                      fontFamily: 'Oswald')),
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

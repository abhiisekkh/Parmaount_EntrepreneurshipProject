import 'package:flutter/material.dart';
import 'ui/database_viewer.dart';
import 'ui/attendance_seeder.dart';
import 'ui/action_grid.dart';
import 'ui/event_section.dart';
import 'ui/profile_header.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Teacher Dashboard'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHeader(
                    name: 'Mr. Sunil Sharma',
                    subtitle: 'Computer Science Department',
                    imageUrl: 'assets/images/sunil.jpg',
                  ),
                  const SizedBox(height: 32),
                  ActionGrid(
                    items: [
                      ActionGridItem(
                        icon: Icons.person_add_alt_1,
                        label: 'Add Student',
                        onTap: () => Navigator.of(context).pushNamed('/add_student'),
                        color: Colors.purple.shade100,
                        iconColor: Colors.purple.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.edit_calendar,
                        label: 'Mark Attendance',
                        onTap: () => Navigator.of(context).pushNamed('/attendance'),
                        color: Colors.red.shade100,
                        iconColor: Colors.red.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.upload_file,
                        label: 'Upload Grades',
                        onTap: () => _showMessage(context, 'Grade upload feature is in development.'),
                        color: Colors.lightBlue.shade100,
                        iconColor: Colors.lightBlue.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.announcement,
                        label: 'Send Announcement',
                        onTap: () => _showMessage(context, 'Announcement feature coming soon!'),
                        color: Colors.amber.shade100,
                        iconColor: Colors.amber.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.storage,
                        label: 'View Database',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const DatabaseViewer()),
                        ),
                        color: Colors.green.shade100,
                        iconColor: Colors.green.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.restore,
                        label: 'Restore Data',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AttendanceSeeder()),
                        ),
                        color: Colors.orange.shade100,
                        iconColor: Colors.orange.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  EventSection(
                    sectionTitle: 'My Teaching Courses',
                    events: [
                      EventItem(
                        title: 'Data Structures',
                        date: 'CS301 | 60 students',
                        description: 'Next class: Mon, 10:00 AM',
                        icon: Icons.class_,
                        color: Colors.indigo.shade50,
                      ),
                      EventItem(
                        title: 'Algorithms',
                        date: 'CS302 | 55 students',
                        description: 'Next class: Tue, 12:00 PM',
                        icon: Icons.class_,
                        color: Colors.indigo.shade50,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMessage(context, 'No new notifications for teachers.'),
        tooltip: 'Notifications',
        child: const Icon(Icons.notifications),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Information'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(dialogContext).primaryColor)),
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

import 'package:flutter/material.dart';
import 'ui/profile_header.dart';
import 'ui/action_grid.dart';
import 'ui/event_section.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Student Dashboard'),
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
                    name: 'Aaryan Upadhyay',
                    subtitle: 'B.Tech Computer Science, 5th Semester',
                    imageUrl: 'assets/images/girl.png',
                  ),
                  const SizedBox(height: 32),
                  ActionGrid(
                    items: [
                      ActionGridItem(
                        icon: Icons.calendar_today,
                        label: 'View Attendance',
                        onTap: () => Navigator.of(context).pushNamed('/student_attendance'),
                        color: Colors.teal.shade100,
                        iconColor: Colors.teal.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.grade,
                        label: 'Check Grades',
                        onTap: () => _showMessage(context, 'Grades for 5th Semester are available soon!'),
                        color: Colors.orange.shade100,
                        iconColor: Colors.orange.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.assignment,
                        label: 'Assignments',
                        onTap: () => _showMessage(context, 'No pending assignments.'),
                        color: Colors.blue.shade100,
                        iconColor: Colors.blue.shade700,
                      ),
                      ActionGridItem(
                        icon: Icons.payment,
                        label: 'Fee Status',
                        onTap: () => _showMessage(context, 'Your fee for this semester is paid.'),
                        color: Colors.green.shade100,
                        iconColor: Colors.green.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  EventSection(
                    sectionTitle: 'Upcoming Events',
                    events: [
                      EventItem(
                        title: 'Mid-Term Exams',
                        date: 'October 25 - Nov 5',
                        description: 'Prepare well for your upcoming mid-term examinations.',
                        icon: Icons.book,
                        color: Colors.purple.shade50,
                      ),
                      EventItem(
                        title: 'Annual Sports Day',
                        date: 'December 12',
                        description: 'Join us for a day of fun and sports activities.',
                        icon: Icons.sports_soccer,
                        color: Colors.blue.shade50,
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
        onPressed: () => _showMessage(context, 'No new notifications.'),
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

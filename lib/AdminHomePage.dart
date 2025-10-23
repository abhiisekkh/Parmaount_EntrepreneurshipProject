import 'package:flutter/material.dart';
import 'ui/profile_header.dart';
import 'ui/action_grid.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Admin Dashboard'),
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
                    name: 'Admin',
                    subtitle: 'Welcome, Admin!',
                    imageUrl: null,
                  ),
                  const SizedBox(height: 32),
                  ActionGrid(
                    items: [
                      ActionGridItem(
                        icon: Icons.group,
                        label: 'Manage Students',
                        onTap: () => Navigator.of(context).pushNamed('/admin/students'),
                        color: Colors.deepPurple.shade100,
                        iconColor: Colors.deepPurple,
                      ),
                      ActionGridItem(
                        icon: Icons.person,
                        label: 'Manage Faculty',
                        onTap: () => Navigator.of(context).pushNamed('/admin/faculty'),
                        color: Colors.blue.shade100,
                        iconColor: Colors.blue.shade800,
                      ),
                      ActionGridItem(
                        icon: Icons.book,
                        label: 'Manage Courses',
                        onTap: () => Navigator.of(context).pushNamed('/admin/courses'),
                        color: Colors.green.shade100,
                        iconColor: Colors.green.shade800,
                      ),
                      ActionGridItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        onTap: () => _showMessage(context, 'Settings options coming soon.'),
                        color: Colors.amber.shade100,
                        iconColor: Colors.amber.shade800,
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
        onPressed: () => _showMessage(context, 'No new notifications for admin.'),
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

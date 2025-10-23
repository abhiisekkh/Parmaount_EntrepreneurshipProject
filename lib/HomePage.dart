import 'package:flutter/material.dart';
import 'ui/profile_header.dart';
import 'ui/action_grid.dart';
import 'ui/event_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/faculty');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/auth');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Paramount Pathshala'),
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
                  // Hero/Profile Section
                  const ProfileHeader(
                    name: 'Guest',
                    subtitle: 'Welcome to Paramount Institute',
                    imageUrl: null,
                  ),
                  const SizedBox(height: 32),
                  // Action Grid
                  ActionGrid(
                    items: [
                      ActionGridItem(
                        icon: Icons.school_outlined,
                        label: 'Students',
                        onTap: () => Navigator.pushNamed(context, '/auth'),
                        color: Colors.deepPurple.shade100,
                        iconColor: Colors.deepPurple,
                      ),
                      ActionGridItem(
                        icon: Icons.person_outline,
                        label: 'Teachers',
                        onTap: () => Navigator.pushNamed(context, '/auth'),
                        color: Colors.blue.shade100,
                        iconColor: Colors.blue.shade800,
                      ),
                      ActionGridItem(
                        icon: Icons.how_to_reg_outlined,
                        label: 'Admissions',
                        onTap: () => _showMessage(context, 'Admissions are open! Contact us for more details.'),
                        color: Colors.green.shade100,
                        iconColor: Colors.green.shade800,
                      ),
                      ActionGridItem(
                        icon: Icons.info_outline,
                        label: 'About Us',
                        onTap: () => _showMessage(context, 'Learn more about Paramount Institute.'),
                        color: Colors.amber.shade100,
                        iconColor: Colors.amber.shade800,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Events/Announcements
                  EventSection(
                    sectionTitle: 'Announcements',
                    events: [
                      EventItem(
                        title: 'Admissions Open',
                        date: 'Apply by 30th Sept',
                        description: 'Enroll now for the 2025-26 academic year.',
                        icon: Icons.campaign,
                        color: Colors.green.shade50,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMessage(context, 'Contact us at: info@paramount.edu or call +91-1234567890');
        },
        label: const Text('Contact Us'),
        icon: const Icon(Icons.call),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavBarTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.group),
            label: 'Faculty',
          ),
          NavigationDestination(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
        ],
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

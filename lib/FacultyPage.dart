import 'package:flutter/material.dart';

class FacultyPage extends StatelessWidget {
  const FacultyPage({super.key});

  // Dummy faculty data
  final List<Map<String, String>> facultyMembers = const [
    {
      'name': 'Dr. Sunil Upadhyay',
      'designation': 'Head of Department, Computer Science',
      'email': 'sunil.upadhyay@paramount.edu',
      'image': 'assets/images/sunil.jpg', // Placeholder for a faculty image
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Esteemed Faculty'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: facultyMembers.length,
        itemBuilder: (context, index) {
          final faculty = facultyMembers[index];
          return FacultyCard(
            name: faculty['name']!,
            designation: faculty['designation']!,
            email: faculty['email']!,
            imageUrl: faculty['image']!,
          );
        },
      ),
    );
  }
}

// Custom widget for displaying individual faculty member details
class FacultyCard extends StatelessWidget {
  final String name;
  final String designation;
  final String email;
  final String imageUrl;

  const FacultyCard({
    super.key,
    required this.name,
    required this.designation,
    required this.email,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.deepPurple.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: AssetImage(imageUrl), // Faculty member's image
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback if image fails to load
                debugPrint('Error loading faculty image: $exception');
              },
              child: imageUrl.isEmpty // Agar image na ho toh fallback icon
                  ? Icon(Icons.person, size: 50, color: Colors.deepPurple.shade700)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade900,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    designation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple.shade700,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'Oswald',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Email function or profile view
                        _showMessage(context, 'Contacting $name at $email');
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('View Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.deepPurple.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

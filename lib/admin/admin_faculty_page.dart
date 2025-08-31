import 'package:flutter/material.dart';
import '../services/test_data_service.dart';

class AdminFacultyPage extends StatefulWidget {
  const AdminFacultyPage({super.key});

  @override
  State<AdminFacultyPage> createState() => _AdminFacultyPageState();
}

class _AdminFacultyPageState extends State<AdminFacultyPage> {
  final TestDataService _testDataService = TestDataService();
  List<Map<String, dynamic>> _faculty = [];

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  void _loadFaculty() {
    setState(() {
      _faculty = _testDataService.getAllFaculty();
    });
  }

  Future<void> _deleteFaculty(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to remove this faculty member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final faculty = _testDataService.getFacultyById(id);
              if (faculty != null) {
                _testDataService.getAllFaculty().remove(faculty);
                setState(() {
                  _faculty.remove(faculty);
                });
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Faculty member removed successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Faculty'),
      ),
      body: ListView.builder(
        itemCount: _faculty.length,
        itemBuilder: (context, index) {
          final faculty = _faculty[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(faculty['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faculty['department']),
                  Text('Subjects: ${(faculty['subjects'] as List).join(", ")}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit faculty page
                      Navigator.pushNamed(context, '/admin/faculty/edit', arguments: faculty);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteFaculty(faculty['id']),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin/faculty/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

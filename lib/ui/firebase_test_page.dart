import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  bool _isConnected = false;
  bool _isTesting = false;
  String _status = 'Not tested';
  int _userCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Firebase Status: $_status',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Project ID: paramountclasses-78104'),
                    Text('Users in database: $_userCount'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTesting ? null : _testFirebaseConnection,
              child: _isTesting 
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test Firebase Connection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConnected ? _createTestUser : null,
              child: const Text('Create Test User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConnected ? _viewFirestore : null,
              child: const Text('View Firestore Collections'),
            ),
            const SizedBox(height: 20),
            if (_isConnected)
              const Card(
                color: Color(0xFFE7F5E7),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Firebase is Connected!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your backend is now live and ready to use. Data will be saved to your Firebase database.',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing...';
    });

    try {
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      
      // Count total users
      final allUsersSnapshot = await firestore
          .collection(FirebaseConfig.usersCollection)
          .get();

      setState(() {
        _isConnected = true;
        _status = 'Connected';
        _userCount = allUsersSnapshot.docs.length;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _status = 'Connection failed: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Firebase connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _createTestUser() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      await firestore
          .collection(FirebaseConfig.usersCollection)
          .add({
        'name': 'Test User',
        'email': 'test@paramount.edu',
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Refresh user count
      final allUsersSnapshot = await firestore
          .collection(FirebaseConfig.usersCollection)
          .get();

      setState(() {
        _userCount = allUsersSnapshot.docs.length;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test user created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to create test user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Get all collections
      final collections = [
        FirebaseConfig.usersCollection,
        FirebaseConfig.attendanceCollection,
        FirebaseConfig.subjectsCollection,
        FirebaseConfig.classesCollection,
      ];

      String collectionsInfo = '';
      for (String collection in collections) {
        final snapshot = await firestore.collection(collection).get();
        collectionsInfo += '$collection: ${snapshot.docs.length} documents\n';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Firestore Collections'),
            content: Text(collectionsInfo),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to view collections: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
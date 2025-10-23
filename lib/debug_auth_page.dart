import 'package:flutter/material.dart';
import 'services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugAuthPage extends StatefulWidget {
  const DebugAuthPage({super.key});

  @override
  State<DebugAuthPage> createState() => _DebugAuthPageState();
}

class _DebugAuthPageState extends State<DebugAuthPage> {
  final UserService _userService = UserService();
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final buffer = StringBuffer();
    
    try {
      // Check Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      buffer.writeln('=== AUTHENTICATION STATUS ===');
      buffer.writeln('Current User: ${user?.email ?? 'NOT LOGGED IN'}');
      buffer.writeln('User UID: ${user?.uid ?? 'N/A'}');
      buffer.writeln('Email Verified: ${user?.emailVerified ?? 'N/A'}');
      buffer.writeln('UserService.isAuthenticated: ${_userService.isAuthenticated}');
      buffer.writeln('');
      
      if (user != null) {
        // Test Firestore connection
        buffer.writeln('=== FIRESTORE TEST ===');
        try {
          final testDoc = await FirebaseFirestore.instance
              .collection('users')
              .limit(1)
              .get();
          buffer.writeln('✅ Firestore connection: SUCCESS');
          buffer.writeln('Documents found: ${testDoc.docs.length}');
        } catch (firestoreError) {
          buffer.writeln('❌ Firestore connection: FAILED');
          buffer.writeln('Error: $firestoreError');
        }
        
        // Test user document
        buffer.writeln('');
        buffer.writeln('=== USER DOCUMENT TEST ===');
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          buffer.writeln('User document exists: ${userDoc.exists}');
          if (userDoc.exists) {
            buffer.writeln('User data: ${userDoc.data()}');
          }
        } catch (userDocError) {
          buffer.writeln('❌ User document access: FAILED');
          buffer.writeln('Error: $userDocError');
        }
      }
      
    } catch (e) {
      buffer.writeln('❌ Error during auth check: $e');
    }
    
    setState(() {
      _debugInfo = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAuthStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authentication Debug Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _debugInfo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
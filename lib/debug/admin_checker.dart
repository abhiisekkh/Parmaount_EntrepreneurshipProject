import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AdminChecker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if current user has admin privileges
  static Future<Map<String, dynamic>> checkCurrentUserAdmin() async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'isAuthenticated': false,
      'hasFirebaseUser': false,
      'hasFirestoreDoc': false,
      'firestoreRole': null,
      'isAdmin': false,
      'isDemoAdmin': false,
      'errors': <String>[],
    };

    try {
      // Check authentication
      final currentUser = AuthService.currentUser;
      result['hasFirebaseUser'] = currentUser != null;
      
      if (currentUser != null) {
        result['isAuthenticated'] = true;
        result['firebaseUID'] = currentUser.uid;
        result['firebaseEmail'] = currentUser.email;
        
        print('🔍 === ADMIN CHECKER DEBUG ===');
        print('Firebase UID: ${currentUser.uid}');
        print('Firebase Email: ${currentUser.email}');
        
        // Check Firestore document
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection(FirebaseConfig.usersCollection)
              .doc(currentUser.uid)
              .get();
          
          result['hasFirestoreDoc'] = userDoc.exists;
          
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>?;
            result['firestoreData'] = data;
            
            if (data != null) {
              result['firestoreRole'] = data['role'];
              
              print('📄 Firestore Document Found:');
              print('  - Role field: "${data['role']}"');
              print('  - Name: "${data['name']}"');
              print('  - Email: "${data['email']}"');
              print('  - All fields: ${data.keys.toList()}');
              
              // Check if role is exactly "admin"
              final role = data['role'];
              if (role == 'admin') {
                result['isAdmin'] = true;
                print('✅ Role matches "admin" exactly');
              } else {
                result['errors'].add('Role is "$role" but should be exactly "admin"');
                print('❌ Role mismatch: "$role" != "admin"');
              }
            } else {
              result['errors'].add('Firestore document exists but data is null');
              print('❌ Firestore document data is null');
            }
          } else {
            result['errors'].add('No Firestore document found for UID: ${currentUser.uid}');
            print('❌ No Firestore document found for UID: ${currentUser.uid}');
          }
        } catch (e) {
          result['errors'].add('Firestore access error: $e');
          print('❌ Firestore error: $e');
        }
      } else {
        result['errors'].add('No authenticated Firebase user');
        print('❌ No authenticated Firebase user');
      }
      
      // Check demo admin status
      result['isDemoAdmin'] = AuthService.isDemoAdmin();
      if (result['isDemoAdmin'] == true) {
        print('✅ Demo admin credentials detected');
        result['isAdmin'] = true;
      }
      
      print('🎯 Final Result: Admin = ${result['isAdmin']}');
      print('==========================================');
      
    } catch (e) {
      result['errors'].add('General error: $e');
      print('❌ General error in AdminChecker: $e');
    }

    return result;
  }

  /// List all admin users in Firestore
  static Future<List<Map<String, dynamic>>> listAllAdminUsers() async {
    try {
      print('🔍 Searching for all admin users in Firestore...');
      
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('role', isEqualTo: 'admin')
          .get();
      
      final adminUsers = <Map<String, dynamic>>[];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          adminUsers.add({
            'uid': doc.id,
            'name': data['name'],
            'email': data['email'],
            'role': data['role'],
            'createdAt': data['createdAt'],
          });
        }
      }
      
      print('📋 Found ${adminUsers.length} admin users:');
      for (var user in adminUsers) {
        print('  - ${user['name']} (${user['email']}) - UID: ${user['uid']}');
      }
      
      return adminUsers;
    } catch (e) {
      print('❌ Error listing admin users: $e');
      return [];
    }
  }

  /// Create a test admin user (for development only)
  static Future<bool> createTestAdminUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔧 Creating test admin user...');
      
      // This would use AuthService.createUserWithEmailAndPassword
      // but set the role to admin directly
      UserModel? newUser = await AuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: '1234567890',
        role: UserRole.admin,
      );
      
      if (newUser != null) {
        print('✅ Test admin user created successfully');
        print('   Email: $email');
        print('   UID: ${newUser.uid}');
        print('   Role: ${newUser.role.name}');
        return true;
      } else {
        print('❌ Failed to create test admin user');
        return false;
      }
    } catch (e) {
      print('❌ Error creating test admin user: $e');
      return false;
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/user_model.dart';

/// Utility class for debugging and cleaning up user creation issues
class UserDebugUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if current user has corresponding Firestore document
  static Future<Map<String, dynamic>> checkCurrentUserConsistency() async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'hasAuthUser': false,
      'hasFirestoreDoc': false,
      'isConsistent': false,
      'authUserDetails': null,
      'firestoreDetails': null,
      'issues': <String>[],
    };

    try {
      final currentUser = _auth.currentUser;
      result['hasAuthUser'] = currentUser != null;

      if (currentUser != null) {
        result['authUserDetails'] = {
          'uid': currentUser.uid,
          'email': currentUser.email,
          'displayName': currentUser.displayName,
          'emailVerified': currentUser.emailVerified,
          'creationTime': currentUser.metadata.creationTime?.toIso8601String(),
          'lastSignInTime': currentUser.metadata.lastSignInTime?.toIso8601String(),
        };

        print('🔍 === USER CONSISTENCY CHECK ===');
        print('Auth User UID: ${currentUser.uid}');
        print('Auth User Email: ${currentUser.email}');

        // Check Firestore document
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection(FirebaseConfig.usersCollection)
              .doc(currentUser.uid)
              .get();

          result['hasFirestoreDoc'] = userDoc.exists;

          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>?;
            result['firestoreDetails'] = data;

            print('✅ Firestore document found');
            print('   Role: ${data?['role']}');
            print('   Name: ${data?['name']}');
            print('   Email: ${data?['email']}');

            result['isConsistent'] = true;
          } else {
            print('❌ No Firestore document found for Auth user');
            result['issues'].add('Auth user exists but no Firestore document found');
          }
        } catch (e) {
          print('❌ Error accessing Firestore: $e');
          result['issues'].add('Firestore access error: $e');
        }
      } else {
        print('❌ No authenticated user');
        result['issues'].add('No authenticated user found');
      }

      print('🎯 Consistency Result: ${result['isConsistent']}');
      print('==========================================');

    } catch (e) {
      print('❌ Error in consistency check: $e');
      result['issues'].add('General error: $e');
    }

    return result;
  }

  /// Find orphaned Firebase Auth users (exist in Auth but not in Firestore)
  static Future<List<Map<String, dynamic>>> findOrphanedAuthUsers() async {
    print('🔍 === SEARCHING FOR ORPHANED AUTH USERS ===');
    print('Note: This requires manual verification as Firebase Auth doesn\'t allow listing all users from client SDK');
    
    // This method is limited - Firebase Auth doesn't allow listing all users from client SDK
    // It can only check the current user or users you have UIDs for
    
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final consistency = await checkCurrentUserConsistency();
      if (!consistency['isConsistent']) {
        print('⚠️ Current user is orphaned (Auth exists but no Firestore doc)');
        return [consistency['authUserDetails']];
      }
    }

    print('ℹ️ No orphaned users found in current session');
    print('ℹ️ Note: Full orphan detection requires Firebase Admin SDK');
    return [];
  }

  /// Test user creation with specific error scenarios
  static Future<Map<String, dynamic>> testUserCreation(String testEmail) async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'testEmail': testEmail,
      'steps': <String, dynamic>{},
      'errors': <String>[],
      'success': false,
    };

    try {
      print('🧪 === TESTING USER CREATION: $testEmail ===');

      // Step 1: Create Auth user
      print('Step 1: Creating Auth user...');
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: testEmail,
          password: 'testpassword123',
        );

        final createdUser = userCredential.user;
        if (createdUser == null) {
          throw Exception('Auth createUser returned null user');
        }

        final String uid = createdUser.uid;
        result['steps']['authCreation'] = 'SUCCESS';
        result['authUid'] = uid;
        print('✅ Auth user created successfully - UID: $uid');

        // Step 2: Try to create Firestore document (with detailed sanitization/type logging)
        print('Step 2: Testing Firestore document creation...');
        try {
          final testUser = UserModel(
            uid: uid,
            email: testEmail,
            name: 'Test User',
            role: UserRole.student,
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

          final Map<String, dynamic> payload = testUser.toJson();
          print('ℹ️ Payload prepared for Firestore (sanitized):');
          payload.forEach((k, v) {
            print('  - $k: ${v.runtimeType} -> $v');
          });

          await _firestore
              .collection(FirebaseConfig.usersCollection)
              .doc(uid)
              .set(payload);

          result['steps']['firestoreCreation'] = 'SUCCESS';
          result['success'] = true;
          print('✅ Firestore document created successfully for UID: $uid');

          // Clean up test user: delete Firestore doc first, then Auth user
          try {
            await _firestore.collection(FirebaseConfig.usersCollection).doc(uid).delete();
            print('✅ Test Firestore document deleted');
          } catch (cleanupFsError) {
            print('⚠️ Failed to delete test Firestore doc: $cleanupFsError');
            result['errors'].add('Failed to delete test Firestore doc: $cleanupFsError');
          }

          try {
            await createdUser.delete();
            print('✅ Test Auth user deleted');
          } catch (cleanupAuthError) {
            print('⚠️ Failed to delete test Auth user: $cleanupAuthError');
            result['errors'].add('Failed to delete test Auth user: $cleanupAuthError');
          }

        } catch (firestoreError, firestoreStack) {
          result['steps']['firestoreCreation'] = 'FAILED';
          result['errors'].add('Firestore creation failed: $firestoreError');
          result['firestoreStack'] = firestoreStack.toString();
          print('❌ Firestore creation failed: $firestoreError');
          print('StackTrace: $firestoreStack');

          // Try to clean up Firestore doc if partially created, then Auth user
          try {
            final docRef = _firestore.collection(FirebaseConfig.usersCollection).doc(uid);
            final docSnap = await docRef.get();
            if (docSnap.exists) {
              await docRef.delete();
              print('✅ Partial Firestore doc deleted during cleanup');
            }
          } catch (fsCleanupError) {
            print('❌ Failed to cleanup Firestore doc: $fsCleanupError');
            result['errors'].add('Firestore cleanup failed: $fsCleanupError');
          }

          try {
            await createdUser.delete();
            print('✅ Orphaned Auth user cleaned up');
          } catch (cleanupError) {
            print('❌ Failed to clean up Auth user: $cleanupError');
            result['errors'].add('Cleanup failed: $cleanupError');
          }
        }

      } on FirebaseAuthException catch (authError, authStack) {
        result['steps']['authCreation'] = 'FAILED';
        final msg = 'Auth creation failed: ${authError.code} - ${authError.message}';
        result['errors'].add(msg);
        result['authStack'] = authStack.toString();
        print('❌ Auth creation failed: ${authError.code} - ${authError.message}');
        print('StackTrace: $authStack');
      }

    } catch (e) {
      result['errors'].add('General test error: $e');
      print('❌ General test error: $e');
    }

    print('🎯 Test Result: ${result['success'] ? "SUCCESS" : "FAILED"}');
    print('==========================================');

    return result;
  }

  /// Generate comprehensive debug report
  static Future<String> generateDebugReport() async {
    final buffer = StringBuffer();
    buffer.writeln('=== PARAMOUNT USER CREATION DEBUG REPORT ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    // Current user consistency
    buffer.writeln('1. CURRENT USER CONSISTENCY CHECK');
    buffer.writeln('-' * 40);
    final consistency = await checkCurrentUserConsistency();
    buffer.writeln('Has Auth User: ${consistency['hasAuthUser']}');
    buffer.writeln('Has Firestore Doc: ${consistency['hasFirestoreDoc']}');
    buffer.writeln('Is Consistent: ${consistency['isConsistent']}');
    
    if (consistency['authUserDetails'] != null) {
      buffer.writeln('Auth Details: ${consistency['authUserDetails']}');
    }
    
    if (consistency['issues'].isNotEmpty) {
      buffer.writeln('Issues Found:');
      for (String issue in consistency['issues']) {
        buffer.writeln('  - $issue');
      }
    }
    buffer.writeln();

    // Orphaned users check
    buffer.writeln('2. ORPHANED USERS CHECK');
    buffer.writeln('-' * 40);
    final orphaned = await findOrphanedAuthUsers();
    buffer.writeln('Orphaned Users Found: ${orphaned.length}');
    for (var user in orphaned) {
      buffer.writeln('  - UID: ${user['uid']}, Email: ${user['email']}');
    }
    buffer.writeln();

    // Firebase configuration
    buffer.writeln('3. FIREBASE CONFIGURATION');
    buffer.writeln('-' * 40);
    buffer.writeln('Users Collection: ${FirebaseConfig.usersCollection}');
    buffer.writeln('Current User: ${_auth.currentUser?.email ?? 'None'}');
    buffer.writeln();

    return buffer.toString();
  }

  /// Manual cleanup helper for orphaned Auth users
  static Future<bool> cleanupOrphanedAuthUser(String email, String password) async {
    try {
      print('🧹 === MANUAL CLEANUP: $email ===');
      
      // Sign in as the orphaned user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print('✅ Signed in as orphaned user: ${userCredential.user!.uid}');
        
        // Delete the user
        await userCredential.user!.delete();
        print('✅ Orphaned Auth user deleted successfully');
        return true;
      } else {
        print('❌ Failed to sign in as orphaned user');
        return false;
      }
    } catch (e) {
      print('❌ Cleanup failed: $e');
      return false;
    }
  }
}
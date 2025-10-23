import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Demo credentials for quick testing
  static final Map<String, Map<String, String>> _demoCredentials = {
    'Student': {
      'email': 'student@paramount.edu',
      'password': 'student123',
      'route': '/student_home',
    },
    'Teacher': {
      'email': 'teacher@paramount.edu',
      'password': 'teacher123',
      'route': '/teacher_home',
    },
    'Admin': {
      'email': 'admin@paramount.edu',
      'password': 'admin123',
      'route': '/admin_home',
    },
  };

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user stream
  static Stream<User?> get userStream => _auth.authStateChanges();

  // Check if credentials are demo credentials
  static AuthResult? checkDemoCredentials(String email, String password, String role) {
    final demoData = _demoCredentials[role];
    if (demoData != null && 
        email == demoData['email'] && 
        password == demoData['password']) {
      
      // Set the demo role for this session
      setDemoRole(role);
      print('Demo credentials validated for role: $role');
      
      return AuthResult(
        success: true,
        user: null, // Demo user doesn't have Firebase user
        route: demoData['route']!,
        isDemo: true,
        message: 'Demo login successful! Welcome, $role!',
      );
    }
    return null;
  }

  // Unified Sign In Method (handles both demo and Firebase)
  static Future<AuthResult> signInUnified({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // First try demo credentials
      final demoResult = checkDemoCredentials(email, password, role);
      if (demoResult != null) {
        return demoResult;
      }

      // Try Firebase authentication
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          final route = _getRouteForRole(userModel.role);
          
          return AuthResult(
            success: true,
            user: userCredential.user,
            route: route,
            isDemo: false,
            message: 'Welcome back, ${userModel.name}!',
          );
        } else {
          // User exists in Firebase Auth but not in Firestore
          return AuthResult(
            success: false,
            error: 'User profile not found. Please contact support.',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Authentication failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: _handleAuthException(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // NEW: Automatic Role-Based Sign In (without manual role selection)
  static Future<AuthResult> signInAutomatic({
    required String email,
    required String password,
  }) async {
    try {
      print('=== Attempting automatic sign-in for: $email ===');
      
      // First check if it matches any demo credentials
      for (String role in _demoCredentials.keys) {
        final demoData = _demoCredentials[role];
        if (demoData != null && 
            email.trim() == demoData['email'] && 
            password == demoData['password']) {
          print('Demo credentials matched for role: $role');
          
          // Set the demo role for this session
          setDemoRole(role);
          
          return AuthResult(
            success: true,
            user: null, // Demo user doesn't have Firebase user
            route: demoData['route']!,
            isDemo: true,
            message: 'Demo login successful! Welcome, $role!',
          );
        }
      }

      print('Not demo credentials, attempting Firebase authentication...');
      
      // Try Firebase authentication
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        print('Firebase authentication successful, fetching user profile...');
        
        // Get user data from Firestore to determine role
        DocumentSnapshot userDoc = await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          final route = _getRouteForRole(userModel.role);
          
          print('User role determined: ${userModel.role.name} -> Route: $route');
          
          return AuthResult(
            success: true,
            user: userCredential.user,
            route: route,
            isDemo: false,
            message: 'Welcome back, ${userModel.name}! Redirecting to ${userModel.role.name} dashboard...',
          );
        } else {
          // User exists in Firebase Auth but not in Firestore
          print('User authenticated but no Firestore profile found');
          return AuthResult(
            success: false,
            error: 'User profile not found. Please contact support to set up your profile.',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Authentication failed. Please check your credentials.',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        error: _handleAuthException(e),
      );
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Sign in with email and password
  static Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Create user with email and password (Legacy - for backward compatibility)
  static Future<UserModel?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? studentId,
    String? teacherId,
    String? course,
    int? semester,
    List<String>? subjectsTaught,
    List<String>? classesAssigned,
  }) async {
    UserCredential? userCredential; // Declare outside try-catch for potential cleanup
    String? userId; // Store userId for potential cleanup

    try {
      print('--- DEBUG: AuthService.createUserWithEmailAndPassword START ---');
      print('Attempting to create Auth user for: $email');
      print('Role: ${role.name}, Name: $name, Phone: $phone');

      // Create Firebase Auth user
      print('ℹ️ DEBUG: Calling Firebase Auth createUserWithEmailAndPassword...');
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        print('❌ DEBUG: Firebase Auth user is null after creation attempt.');
        throw Exception('Firebase Auth user creation returned null.');
      }
      
      userId = user.uid; // Store UID for potential cleanup
      print('✅ DEBUG: Firebase Auth user created successfully. UID: $userId');
      print('✅ DEBUG: Firebase Auth user email: ${user.email}');

      // Create user model
      print('ℹ️ DEBUG: Creating UserModel object...');
      UserModel newUser = UserModel(
        uid: user.uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        phoneNumber: phone.trim(),
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        studentId: studentId,
        teacherId: teacherId,
        course: course,
        semester: semester,
        subjectsTaught: subjectsTaught ?? <String>[],
        classesAssigned: classesAssigned ?? <String>[],
      );
      
      print('✅ DEBUG: UserModel created successfully');
      print('ℹ️ DEBUG: UserModel data: ${newUser.toJson()}');

      // Save user data to Firestore using sanitized data
      print('ℹ️ DEBUG: Attempting to write user document to Firestore...');
      print('ℹ️ DEBUG: Collection: ${FirebaseConfig.usersCollection}');
      print('ℹ️ DEBUG: Document ID: ${user.uid}');

      try {
        final sanitized = newUser.toJson();
        print('ℹ️ DEBUG: Sanitized user data prepared for Firestore: $sanitized');
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(user.uid)
            .set(sanitized);

        print('✅ DEBUG: Firestore document written successfully for UID: ${user.uid}');
      } catch (firestoreError, firestoreStack) {
        print('❌ DEBUG: Firestore write failed: $firestoreError');
        print('ℹ️ DEBUG: StackTrace: $firestoreStack');

        // Attempt rollback: delete the created Firebase Auth user to avoid orphaned accounts
        try {
          print('⚠️ DEBUG: Attempting rollback - deleting Auth user ${user.uid}');
          await user.delete();
          print('✅ DEBUG: Rollback succeeded - deleted Auth user ${user.uid}');
        } catch (deleteError) {
          print('❌ DEBUG: Rollback failed - could not delete Auth user ${user.uid}: $deleteError');
          print('ℹ️ Manual cleanup required: Delete user ${user.uid} from Firebase Console');
        }

        // Re-throw to be handled by outer catch
        rethrow;
      }

      // Update user profile display name
      try {
        print('ℹ️ DEBUG: Updating Firebase Auth display name...');
        await user.updateDisplayName(name.trim());
        print('✅ DEBUG: Firebase Auth display name updated successfully.');
      } catch (displayNameError) {
        print('⚠️ DEBUG: Failed to update Firebase Auth display name: $displayNameError');
        // Non-critical, continue execution
      }

      print('--- DEBUG: AuthService.createUserWithEmailAndPassword END (Success) ---');
      return newUser;

    } on FirebaseAuthException catch (e) {
      print('❌ DEBUG: FirebaseAuthException in createUserWithEmailAndPassword: ${e.code} - ${e.message}');
      print('❌ DEBUG: Full FirebaseAuthException: $e');
      // If Auth creation failed, no cleanup needed here
      throw _handleAuthException(e); // Re-throw handled exception
    } catch (e, stackTrace) { // Catch ANY other error
      print('❌ DEBUG: Generic Exception in AuthService.createUserWithEmailAndPassword: $e');
      print('ℹ️ DEBUG: Exception Type: ${e.runtimeType}');
      print('ℹ️ DEBUG: StackTrace: $stackTrace');

      // *** Rollback Logic (Optional but Recommended) ***
      // If Firestore write failed AFTER Auth was created, try deleting the Auth user
      if (userId != null && userCredential?.user != null) {
        print('⚠️ DEBUG: Firestore write failed after Auth user ($userId) was created. Attempting Auth user deletion...');
        try {
          await userCredential!.user!.delete();
          print('✅ DEBUG: Successfully deleted orphaned Auth user $userId');
        } catch (deleteError) {
          print('❌ DEBUG: Failed to delete orphaned Auth user $userId: $deleteError');
          print('ℹ️ Manual Cleanup Required: Delete Auth user $userId ($email) from Firebase Console.');
        }
      }
      // *** End Rollback Logic ***

      print('--- DEBUG: AuthService.createUserWithEmailAndPassword END (Error) ---');
      // Throw a more specific error or the original one
      throw Exception('Failed during user creation process: $e');
    }
  }

  // Unified Registration Method
  static Future<AuthResult> registerUnified({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? studentId,
    String? teacherId,
    String? course,
    int? semester,
    List<String>? subjectsTaught,
    List<String>? classesAssigned,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Create user model
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email.trim(),
          name: name.trim(),
          role: role,
          phoneNumber: phone.trim(),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          studentId: studentId,
          teacherId: teacherId,
          course: course,
          semester: semester,
          subjectsTaught: subjectsTaught ?? <String>[],
          classesAssigned: classesAssigned ?? <String>[],
        );

        // Save user data to Firestore
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());

        // Update user profile
        await userCredential.user!.updateDisplayName(name);

        final route = _getRouteForRole(role);

        return AuthResult(
          success: true,
          user: userCredential.user,
          route: route,
          isDemo: false,
          message: 'Account created successfully! Welcome, $name!',
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Failed to create account. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: _handleAuthException(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Get current user data from Firestore
  static Future<UserModel?> getCurrentUserData() async {
    try {
      print('=== getCurrentUserData called ===');
      
      if (currentUser == null) {
        print('No current Firebase user - returning null');
        return null;
      }
      
      print('Fetching user data for UID: ${currentUser!.uid}');
      print('Firestore collection: ${FirebaseConfig.usersCollection}');
      
      DocumentSnapshot userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        print('User document found in Firestore ✅');
        final userData = userDoc.data() as Map<String, dynamic>?;
        print('User document data: $userData');
        
        UserModel user = UserModel.fromFirestore(userDoc);
        print('UserModel created - Name: ${user.name}, Role: ${user.role.name}, Email: ${user.email}');
        return user;
      } else {
        print('No document found for UID: ${currentUser!.uid}');
        return null;
      }
    } catch (e) {
      print('Error in getCurrentUserData: $e');
      throw 'Failed to get user data: $e';
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
    String? course,
    int? semester,
    List<String>? subjectsTaught,
    List<String>? classesAssigned,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name.trim();
      if (phone != null) updateData['phoneNumber'] = phone.trim();
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (course != null) updateData['course'] = course;
      if (semester != null) updateData['semester'] = semester;
      if (subjectsTaught != null) updateData['subjectsTaught'] = subjectsTaught;
      if (classesAssigned != null) updateData['classesAssigned'] = classesAssigned;

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update(updateData);

      // Update Firebase Auth profile if name changed
      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name);
      }
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Reset password (Legacy - for backward compatibility)
  static Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Reset password with AuthResult
  static Future<AuthResult> resetPasswordWithResult({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent to ${email.trim()}',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: _handleAuthException(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to send password reset email: ${e.toString()}',
      );
    }
  }

  // Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (currentUser == null) {
        throw 'No user is currently signed in.';
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to change password. Please try again.';
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Clear demo role on logout
      clearDemoRole();
      print('User signed out and demo role cleared');
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Delete user account
  static Future<void> deleteAccount({required String password}) async {
    try {
      if (currentUser == null) {
        throw 'No user is currently signed in.';
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      String userId = currentUser!.uid;

      // Delete user data from Firestore
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .delete();

      // Delete user account
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Verify user role
  static Future<bool> verifyUserRole(UserRole requiredRole) async {
    try {
      print('=== verifyUserRole called for: ${requiredRole.name} ===');
      
      if (currentUser == null) {
        print('No current Firebase user found');
        return false;
      }
      
      print('Current Firebase user UID: ${currentUser!.uid}');
      
      UserModel? user = await getCurrentUserData();
      if (user == null) {
        print('No user data found in Firestore for UID: ${currentUser!.uid}');
        return false;
      }
      
      print('User found - Name: ${user.name}, Role: ${user.role.name}');
      bool hasRole = user.role == requiredRole;
      print('Role verification result: $hasRole (required: ${requiredRole.name}, actual: ${user.role.name})');
      
      return hasRole;
    } catch (e) {
      print('Error in verifyUserRole: $e');
      return false;
    }
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    try {
      print('=== AuthService.isAdmin() called ===');
      
      // First check if we're using demo admin credentials
      if (isDemoAdmin()) {
        print('Demo admin credentials detected ✅');
        return true;
      }
      
      // Check Firebase user role
      bool isFirebaseAdmin = await verifyUserRole(UserRole.admin);
      print('Firebase admin check result: $isFirebaseAdmin');
      return isFirebaseAdmin;
    } catch (e) {
      print('Error in isAdmin(): $e');
      return false;
    }
  }
  
  // Track current demo session (in a real app, use proper state management)
  static String? _currentDemoRole;
  
  // Check if current session is using demo admin credentials
  static bool isDemoAdmin() {
    print('Checking demo admin status - current demo role: $_currentDemoRole');
    return _currentDemoRole == 'Admin';
  }
  
  // Set demo role (call this when demo login is successful)
  static void setDemoRole(String role) {
    print('Setting demo role to: $role');
    _currentDemoRole = role;
  }
  
  // Clear demo role (call this when logging out)
  static void clearDemoRole() {
    print('Clearing demo role');
    _currentDemoRole = null;
  }
  
  // Safe navigation to admin pages with permission check
  static Future<bool> navigateToAdminPage(BuildContext context, String route) async {
    try {
      print('=== Checking admin permission for navigation to: $route ===');
      
      bool hasPermission = await isAdmin();
      
      if (hasPermission) {
        print('Admin permission verified ✅ - Navigating to $route');
        Navigator.pushNamed(context, route);
        return true;
      } else {
        print('Access denied ❌ - User is not admin');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied: Administrator privileges required'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error during admin navigation check: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking permissions: $e'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }

  // Check if user is teacher
  static Future<bool> isTeacher() async {
    return await verifyUserRole(UserRole.teacher);
  }

  // Check if user is student
  static Future<bool> isStudent() async {
    return await verifyUserRole(UserRole.student);
  }

  // Get users by role
  static Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('role', isEqualTo: role.toString().split('.').last)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get users. Please try again.';
    }
  }





  // Phone Number Authentication
  static Future<AuthResult> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed - this will be handled by the calling code
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );

      return AuthResult(
        success: true,
        message: 'Verification code sent to $phoneNumber',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Phone verification failed: ${e.toString()}',
      );
    }
  }

  // Verify Phone Number Code
  static Future<AuthResult> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser) {
        return AuthResult(
          success: true,
          user: userCredential.user,
          route: '/setup_profile',
          isDemo: false,
          message: 'Phone verified! Please complete your profile setup.',
          isNewUser: true,
        );
      } else {
        UserModel? userModel = await _getUserModel(userCredential.user!.uid);
        final route = _getRouteForRole(userModel?.role ?? UserRole.student);
        
        return AuthResult(
          success: true,
          user: userCredential.user,
          route: route,
          isDemo: false,
          message: 'Successfully signed in!',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: _handleAuthException(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Code verification failed: ${e.toString()}',
      );
    }
  }

  // Enhanced Sign Out
  static Future<void> signOutAll() async {
    await _auth.signOut();
    // Clear demo role on logout
    clearDemoRole();
    print('All users signed out and demo role cleared');
  }

  // Helper Methods
  static Future<UserModel?> _getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection(FirebaseConfig.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _getRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/admin_home';
      case UserRole.teacher:
        return '/teacher_home';
      case UserRole.student:
        return '/student_home';
    }
  }



  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

// Auth Result Class
class AuthResult {
  final bool success;
  final User? user;
  final String? route;
  final String? error;
  final String? message;
  final bool isDemo;
  final bool isNewUser;

  AuthResult({
    required this.success,
    this.user,
    this.route,
    this.error,
    this.message,
    this.isDemo = false,
    this.isNewUser = false,
  });
}
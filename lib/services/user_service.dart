import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userCollection = 'users';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      // First sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('No user returned after authentication');
      }
      
      print('Auth successful, fetching user data from Firestore');
      
      // Then immediately fetch the user data from Firestore
      final userDoc = await _firestore
          .collection(userCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found in database');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['uid'] = credential.user!.uid; // Add UID to the data

      print('Successfully retrieved user data: $userData');
      return userData;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('Sign in failed: ${e.message}');
      }
    } catch (e) {
      print('General Exception during sign in: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  // Create new user with email and password
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
    String? studentId,
    String? teacherId,
    String? course,
    int? semester,
  }) async {
    try {
      UserCredential userCredential;
      try {
        // Create auth user with normal flow
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        if (e.toString().contains('operation-not-allowed')) {
          throw Exception('Email/Password sign-in is not enabled. Please enable it in Firebase Console -> Authentication -> Sign-in method.');
        } else if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
          // If reCAPTCHA error occurs, try with a different auth persistence
          await _auth.setPersistence(Persistence.LOCAL);
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final user = userCredential.user!;

      // Create user model
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        studentId: studentId,
        teacherId: teacherId,
        course: course,
        semester: semester,
      );

      // Save user data to Firestore
      await _firestore
          .collection(userCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      print('Fetching user data for UID: $uid');
      final doc = await _firestore.collection(userCollection).doc(uid).get();
      
      if (!doc.exists) {
        print('No document found for UID: $uid');
        return null;
      }

      print('Document data: ${doc.data()}');
      
      if (doc.data() == null) {
        print('Document exists but data is null for UID: $uid');
        return null;
      }

      // Ensure we're dealing with a Map<String, dynamic>
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      
      // Convert any List objects to the correct type
      if (data['subjectsTaught'] != null) {
        data['subjectsTaught'] = List<String>.from(data['subjectsTaught'] as List);
      }
      if (data['classesAssigned'] != null) {
        data['classesAssigned'] = List<String>.from(data['classesAssigned'] as List);
      }

      return UserModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      print('Error fetching user data: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(userCollection).doc(uid).update({
        ...data,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get all students
  Stream<List<UserModel>> getAllStudents() {
    return _firestore
        .collection(userCollection)
        .where('role', isEqualTo: UserRole.student.toString().split('.').last)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Get all teachers
  Stream<List<UserModel>> getAllTeachers() {
    return _firestore
        .collection(userCollection)
        .where('role', isEqualTo: UserRole.teacher.toString().split('.').last)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      // Delete from Authentication
      if (_auth.currentUser?.uid == uid) {
        await _auth.currentUser?.delete();
      }
      
      // Delete from Firestore
      await _firestore.collection(userCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(UserRole role) async* {
    try {
      // First attempt with the index-based query
      yield* _firestore
          .collection(userCollection)
          .where('role', isEqualTo: role.toJson())
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
    } catch (e) {
      if (e.toString().contains('indexes')) {
        // Fallback: fetch all users and filter in memory
        print('Index not found. Using fallback method. Please create the required index.');
        yield* _firestore
            .collection(userCollection)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .where((user) => user.role == role)
                .toList());
      } else {
        // Re-throw if it's not an index error
        throw Exception('Failed to fetch users: $e');
      }
    }
  }
}

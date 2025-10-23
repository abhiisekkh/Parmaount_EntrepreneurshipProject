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

  // Check if user is authenticated and logged in
  bool get isAuthenticated {
    final user = _auth.currentUser;
    if (user == null) {
      print('UserService: No authenticated user found');
      return false;
    }
    print('UserService: User authenticated - ${user.email} (UID: ${user.uid})');
    return true;
  }

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
        return _getDemoUserData(uid);
      }

      print('Document data: ${doc.data()}');
      
      if (doc.data() == null) {
        print('Document exists but data is null for UID: $uid');
        return _getDemoUserData(uid);
      }

      // Ensure we're dealing with a Map<String, dynamic>
      final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      
      // Convert any List objects to the correct type safely
      if (data['subjectsTaught'] != null && data['subjectsTaught'] is List) {
        try {
          data['subjectsTaught'] = (data['subjectsTaught'] as List)
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        } catch (e) {
          print('Error converting subjectsTaught: $e');
          data['subjectsTaught'] = <String>[];
        }
      }
      if (data['classesAssigned'] != null && data['classesAssigned'] is List) {
        try {
          data['classesAssigned'] = (data['classesAssigned'] as List)
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        } catch (e) {
          print('Error converting classesAssigned: $e');
          data['classesAssigned'] = <String>[];
        }
      }

      return UserModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      print('Error fetching user data: $e');
      print('Stack trace: $stackTrace');
      
      // If permission denied, return demo data
      if (e.toString().contains('permission-denied')) {
        print('Permission denied, using demo user data');
        return _getDemoUserData(uid);
      }
      
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
    print('=== getAllStudents called ===');
    
    // Check if user is authenticated
    if (!isAuthenticated) {
      print('No authenticated user found - returning demo data');
      // Return demo data as fallback
      return Stream.value(_getDemoStudents(UserRole.student));
    }

    print('Fetching students from Firestore for authenticated user: ${_auth.currentUser?.email}');
    print('User UID: ${_auth.currentUser?.uid}');
    
    return _firestore
        .collection(userCollection)
        .where('role', isEqualTo: UserRole.student.toString().split('.').last)
        .snapshots()
        .handleError((error) {
          print('Error fetching students from Firestore: $error');
          print('Error type: ${error.runtimeType}');
          if (error.toString().contains('permission-denied')) {
            print('Permission denied - this usually means Firestore rules are blocking access');
            print('Current user: ${_auth.currentUser?.email} (${_auth.currentUser?.uid})');
          }
          // Don't return demo data on error, let the error bubble up to UI
          throw error;
        })
        .map((snapshot) {
          print('Firestore query returned ${snapshot.docs.length} documents');
          if (snapshot.docs.isEmpty) {
            print('No students found in Firestore, returning demo data as fallback');
            return _getDemoStudents(UserRole.student);
          }
          final students = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
          print('Successfully parsed ${students.length} students from Firestore');
          return students;
        });
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
      } else if (e.toString().contains('permission-denied')) {
        // If permission denied, provide demo data
        print('Permission denied, using demo students');
        yield _getDemoStudents(role);
      } else {
        // Re-throw if it's not an index error
        throw Exception('Failed to fetch users: $e');
      }
    }
  }

  // Demo user data for when Firestore is not accessible
  UserModel _getDemoUserData(String uid) {
    // Create demo teacher data
    return UserModel(
      uid: uid,
      email: 'teacher@paramount.edu',
      name: 'Dr. Sarah Johnson',
      role: UserRole.teacher,
      phoneNumber: '+1234567890',
      profileImageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastUpdated: DateTime.now(),
      teacherId: 'TCH001',
      subjectsTaught: [
        'Mathematics',
        'Physics', 
        'Chemistry',
        'Biology',
        'Computer Science'
      ],
      classesAssigned: [
        'Class A',
        'Class B',
        'Class C'
      ],
    );
  }

  // Public method to get demo students for fallback
  List<UserModel> getDemoStudents() {
    return _getDemoStudents(UserRole.student);
  }

  // Demo students data for when Firestore is not accessible
  List<UserModel> _getDemoStudents(UserRole role) {
    if (role != UserRole.student) return [];
    
    return [
      UserModel(
        uid: 'student1',
        email: 'john.doe@student.paramount.edu',
        name: 'John Doe',
        role: UserRole.student,
        phoneNumber: '+1234567891',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastUpdated: DateTime.now(),
        studentId: 'STU001',
        course: 'Computer Science',
        semester: 3,
      ),
      UserModel(
        uid: 'student2',
        email: 'jane.smith@student.paramount.edu',
        name: 'Jane Smith',
        role: UserRole.student,
        phoneNumber: '+1234567892',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        lastUpdated: DateTime.now(),
        studentId: 'STU002',
        course: 'Mathematics',
        semester: 2,
      ),
      UserModel(
        uid: 'student3',
        email: 'bob.wilson@student.paramount.edu',
        name: 'Bob Wilson',
        role: UserRole.student,
        phoneNumber: '+1234567893',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastUpdated: DateTime.now(),
        studentId: 'STU003',
        course: 'Physics',
        semester: 4,
      ),
      UserModel(
        uid: 'student4',
        email: 'alice.brown@student.paramount.edu',
        name: 'Alice Brown',
        role: UserRole.student,
        phoneNumber: '+1234567894',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        lastUpdated: DateTime.now(),
        studentId: 'STU004',
        course: 'Chemistry',
        semester: 1,
      ),
      UserModel(
        uid: 'student5',
        email: 'charlie.davis@student.paramount.edu',
        name: 'Charlie Davis',
        role: UserRole.student,
        phoneNumber: '+1234567895',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastUpdated: DateTime.now(),
        studentId: 'STU005',
        course: 'Biology',
        semester: 2,
      ),
    ];
  }
}

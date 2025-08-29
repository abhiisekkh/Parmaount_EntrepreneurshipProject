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
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
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
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
      final doc = await _firestore.collection(userCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
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
}

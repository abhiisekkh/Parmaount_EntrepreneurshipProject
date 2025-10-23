import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String teachersCollection = 'teachers';
  static const String classesCollection = 'classes';
  static const String subjectsCollection = 'subjects';
  static const String attendanceCollection = 'attendance';
  static const String assignmentsCollection = 'assignments';
  static const String gradesCollection = 'grades';
  static const String notificationsCollection = 'notifications';
  static const String announcementsCollection = 'announcements';
  static const String schedulesCollection = 'schedules';
  
  // Firebase Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String assignmentFilesPath = 'assignment_files';
  static const String documentsPath = 'documents';
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paramount/HomePage.dart';
import 'package:paramount/add_student_page.dart' as legacy;
import 'package:paramount/FacultyPage.dart';
import 'package:paramount/Attendance.dart';
import 'package:paramount/StudentAttendancePage.dart';
import 'package:paramount/student_list_page.dart';
import 'package:paramount/admin/admin_students_page.dart';
import 'package:paramount/admin/admin_faculty_page.dart';
import 'package:paramount/admin/admin_courses_page.dart';
import 'package:paramount/admin/add_faculty_page.dart';
import 'package:paramount/admin/add_student_page.dart';
import 'package:paramount/ui/modern_splash_screen.dart';
import 'package:paramount/ui/modern_auth_page.dart';
import 'package:paramount/ui/registration_page.dart';
import 'package:paramount/ui/modern_admin_dashboard.dart';
import 'package:paramount/ui/modern_student_dashboard.dart';
import 'package:paramount/ui/modern_teacher_dashboard.dart';
import 'package:paramount/ui/database_viewer.dart';
import 'package:paramount/debug_auth_page.dart';
import 'package:paramount/config/firebase_config.dart';
import 'package:paramount/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Firebase configuration
  await FirebaseConfig.initialize();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paramount Institute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF6366F1), // Indigo-500
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1), // Indigo-500
          secondary: const Color(0xFF10B981), // Emerald-500
          tertiary: const Color(0xFFF59E0B), // Amber-500
          background: const Color(0xFFFAFAFA), // Gray-50
          surface: Colors.white,
          surfaceVariant: const Color(0xFFF8FAFC), // Slate-50
          outline: const Color(0xFFE2E8F0), // Slate-200
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF1E293B), // Slate-800
          onBackground: const Color(0xFF1E293B), // Slate-800
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Gray-50
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          // Display styles for large headers
          displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A), // Slate-900
            letterSpacing: -1.0,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          // Headline styles
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.25,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
          // Title styles
          titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
            letterSpacing: 0.1,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            letterSpacing: 0.1,
          ),
          // Body styles
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF475569),
            letterSpacing: 0.1,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
            letterSpacing: 0.1,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
          // Label styles
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        // Modern card theme with subtle shadows
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          color: Colors.white,
          shadowColor: const Color(0xFF64748B).withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          margin: const EdgeInsets.all(8),
        ),
        // Modern app bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.25,
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF475569),
            size: 24,
          ),
          actionsIconTheme: const IconThemeData(
            color: Color(0xFF475569),
            size: 24,
          ),
        ),
        // Modern floating action button
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 6,
          highlightElevation: 8,
        ),
        // Modern input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
        // Modern elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            disabledForegroundColor: const Color(0xFF94A3B8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ),
        // Modern text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ),
        // Modern outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFF6366F1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ),
        // Modern divider theme
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE2E8F0),
          thickness: 1,
          space: 1,
        ),
      ),
      // App ke sabhi routes define kiye hain
      initialRoute: '/',
      routes: {
        '/': (context) => const ModernSplashScreen(),
        '/home': (context) => const HomePage(),
        '/student_home': (context) => const ModernStudentHomePage(),
        '/teacher_home': (context) => const ModernTeacherHomePage(),
        '/add_student': (context) => const legacy.AddStudentPage(),
        '/student_list': (context) => const StudentListPage(),
        '/faculty': (context) => const FacultyPage(),
        '/attendance': (context) => const AttendancePage(),
        '/student_attendance': (context) => const StudentAttendancePage(),
        '/auth': (context) => const ModernAuthPage(),
        '/register': (context) => const RegistrationPage(),
        '/admin_home': (context) => const ModernAdminHomePage(),
        '/admin/students': (context) => const AdminStudentsPage(),
        '/admin/faculty': (context) => const AdminFacultyPage(),
        '/admin/courses': (context) => const AdminCoursesPage(),
        '/admin/attendance': (context) => const AttendancePage(),
        '/admin/faculty/add': (context) => const AddFacultyPage(),
        '/admin/students/add': (context) => const AddStudentPage(),
        '/database_viewer': (context) => const DatabaseViewer(),
        '/debug_auth': (context) => const DebugAuthPage(),
      },
    );
  }
}

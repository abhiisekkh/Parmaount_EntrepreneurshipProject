import 'package:flutter/material.dart';
import 'package:paramount/HomePage.dart';
import 'package:paramount/StudentHomePage.dart';
import 'package:paramount/TeacherHomePage.dart';
import 'package:paramount/add_student_page.dart';
import 'package:paramount/FacultyPage.dart';
import 'package:paramount/Attendance.dart';
import 'package:paramount/StudentAttendancePage.dart';
import 'package:paramount/student_list_page.dart';
import 'package:paramount/auth/auth_page.dart';
import 'package:paramount/admin_home.dart';
import 'package:paramount/admin/admin_students_page.dart';
import 'package:paramount/admin/admin_faculty_page.dart';
import 'package:paramount/admin/admin_courses_page.dart';

void main() {
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
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple.shade700,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.amberAccent.shade400),

        // Font Family ko 'Oswald' set kiya, jaisa ki pubspec.yaml mein define kiya hai
        fontFamily: 'Oswald',

        // Global Text Theme for better design consistency
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w300,
              letterSpacing: -1.5,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade900),
          displayMedium: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade900),
          displaySmall: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w400,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade900),
          headlineLarge: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade900),
          headlineMedium: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade900),
          headlineSmall: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: 'Oswald',
              color: Colors.deepPurple
                  .shade800), // Slightly adjusted size for better hierarchy
          titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade900), // Slightly adjusted size
          titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade800), // Slightly adjusted size
          titleSmall: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade700), // Slightly adjusted size
          bodyLarge: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              fontFamily: 'Oswald',
              color: Colors.grey.shade800), // Slightly adjusted size
          bodyMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
              fontFamily: 'Oswald',
              color: Colors.grey.shade700), // Slightly adjusted size
          bodySmall: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.4,
              fontFamily: 'Oswald',
              color: Colors.grey.shade600), // Slightly adjusted size
          labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.25,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade700), // Adjusted weight
          labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade600), // Adjusted size and weight
          labelSmall: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
              fontFamily: 'Oswald',
              color: Colors.deepPurple.shade500), // Adjusted size
        ).apply(
          bodyColor: Colors.deepPurple.shade900, // Default text color
          displayColor:
              Colors.deepPurple.shade900, // Default display text color
        ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor:
              Colors.deepPurple.shade700, // AppBar background color
          foregroundColor: Colors.white, // AppBar text/icon color
          elevation: 6, // AppBar par thoda zyada shadow
          centerTitle: true, // Title center mein
          titleTextStyle: const TextStyle(
            fontSize: 24, // Thoda bada title
            fontWeight: FontWeight.bold,
            fontFamily: 'Oswald',
            color: Colors.white, // Ensure title text color is white
          ),
          iconTheme: const IconThemeData(
              color: Colors.white,
              size: 26), // AppBar icons white aur thoda bada
          actionsIconTheme: const IconThemeData(
              color: Colors.white,
              size: 26), // Actions icons bhi white aur bade
        ),

        // ElevatedButton Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade600, // Button background
            foregroundColor: Colors.white, // Button text color
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 16), // Thoda zyada padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  18), // Thode zyada rounded corners for buttons
            ),
            textStyle: const TextStyle(
              fontSize: 19, // Thoda bada text
              fontWeight: FontWeight.w600,
              fontFamily: 'Oswald',
            ),
            elevation: 6, // Buttons par thoda zyada elevation
          ),
        ),

        // TextButton Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple.shade700, // TextButton ka color
            textStyle: const TextStyle(
              fontSize: 17, // Thoda bada text
              fontWeight: FontWeight.w500,
              fontFamily: 'Oswald',
            ),
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 10, // Cards par aur zyada shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                22), // Aur zyada rounded corners for cards
          ),
          margin: const EdgeInsets.all(
              14), // Card ke charo taraf thoda zyada margin
          color: Colors.white, // Default card background white
        ),

        // Input Decoration Theme for TextFields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15), // Rounded borders for text fields
            borderSide: BorderSide.none, // No default border line
          ),
          filled: true,
          // ignore: deprecated_member_use
          fillColor: Colors.deepPurple.shade50
              .withOpacity(0.85), // Light fill color, thoda zyada opaque
          contentPadding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 22), // Thoda zyada padding
          labelStyle: TextStyle(
              color: Colors.deepPurple.shade700,
              fontFamily: 'Oswald',
              fontSize: 16), // Font size adjusted
          hintStyle: TextStyle(
              color: Colors.deepPurple.shade300,
              fontFamily: 'Oswald',
              fontSize: 16), // Font size adjusted
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
                color: Colors.deepPurple.shade400,
                width: 2.5), // Thoda mota border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
                color: Colors.deepPurple.shade200,
                width: 1.5), // Thoda mota border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
                color: Colors.red, width: 3), // Aur mota error border
          ),
        ),

        // Dialog Theme for custom alert/info boxes
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25), // Aur zyada rounded dialogs
          ),
          titleTextStyle: TextStyle(
            fontSize: 24, // Bada title
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade900,
            fontFamily: 'Oswald',
          ),
          contentTextStyle: TextStyle(
            fontSize: 17, // Bada content text
            color: Colors.grey.shade700,
            fontFamily: 'Oswald',
          ),
        ),

        // Icon Theme
        iconTheme: IconThemeData(
          color: Colors.deepPurple.shade700, // Default icon color
          size: 26, // Thoda bada icons
        ),

        // Primary Icon Theme (e.g., Drawer header icons, etc.)
        primaryIconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amberAccent.shade400,
          foregroundColor: Colors.deepPurple.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Thode zyada rounded FAB
          ),
          elevation: 8, // FAB par zyada elevation
          extendedTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Oswald',
          ),
        ),

        // Bottom Navigation Bar Theme (agar future mein use ho)
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.deepPurple.shade800,
          selectedItemColor: Colors.amberAccent.shade400,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Oswald', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Oswald'),
          elevation: 10,
        ),

        // Divider Theme
        dividerTheme: DividerThemeData(
          color: Colors.deepPurple.shade100,
          thickness: 1.5,
          space: 20,
        ),
      ),
      // App ke sabhi routes define kiye hain
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/student_home': (context) => const StudentHomePage(),
        '/teacher_home': (context) => const TeacherHomePage(),
        '/add_student': (context) => const AddStudentPage(),
        '/student_list': (context) => const StudentListPage(),
        '/faculty': (context) => const FacultyPage(),
        '/attendance': (context) => const AttendancePage(),
        '/student_attendance': (context) => const StudentAttendancePage(),
        '/auth': (context) => const AuthPage(),
        '/admin_home': (context) => const AdminHomePage(),
        '/admin/students': (context) => const AdminStudentsPage(),
        '/admin/faculty': (context) => const AdminFacultyPage(),
        '/admin/courses': (context) => const AdminCoursesPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'services/user_service.dart';
import 'models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation controller setup kiya
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Animation duration
    );
    // Tween animation jo 0 se 1 tak scale karta hai
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward(); // Animation start kiya

    // Check auth state after animation
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        UserService().getUserData(user.uid).then((userData) {
          if (userData != null && mounted) {
            switch (userData.role) {
              case UserRole.student:
                Navigator.of(context).pushReplacementNamed('/student_home');
                break;
              case UserRole.teacher:
                Navigator.of(context).pushReplacementNamed('/teacher_home');
                break;
              case UserRole.admin:
                Navigator.of(context).pushReplacementNamed('/teacher_home');
                break;
            }
          } else if (mounted) {
            Navigator.of(context).pushReplacementNamed('/auth');
          }
        });
      } else if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Controller ko dispose kiya memory leaks se bachne ke liye
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade800, // Splash screen background color
      body: Center(
        child: ScaleTransition(
          scale: _animation, // Animation apply kiya
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for your app logo/image
              // Assuming you have a logo asset, replace 'assets/images/app_logo.png' with actual path
              Image.asset(
                'assets/images/books.png', // Example image from your assets
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.school,
                    size: 150,
                    color: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 20),
              // App ka naam ya tagline
              const Text(
                'Paramount Institute',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Oswald',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Educating Minds, Shaping Futures',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontFamily: 'Oswald',
                ),
              ),
              const SizedBox(height: 30),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Paramount'),
        actions: [
          // Login button
          TextButton.icon(
            onPressed: () {
              // Yahan par login functionality add kar sakte hain
              _showLoginDialog(context);
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      // Side navigation drawer
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section with a background image and welcome message
            _buildHeroSection(context),
            // Quick access sections for different roles
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Offerings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Firebase Test Card (for development)
                  _buildRoleCard(
                    context,
                    title: 'Firebase Test',
                    description: 'Test Firebase connectivity and features',
                    icon: Icons.cloud_outlined,
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue.shade900,
                    onTap: () => Navigator.pushNamed(context, '/firebase_test'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Attendance Test Card (for development)
                  _buildRoleCard(
                    context,
                    title: 'Attendance Test',
                    description: 'Test Attendance System',
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade100,
                    iconColor: Colors.green.shade900,
                    onTap: () => Navigator.pushNamed(context, '/attendance_test'),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildRoleCard(
                    context,
                    title: 'Students',
                    description: 'Access your courses, attendance, and grades.',
                    icon: Icons.school_outlined,
                    onTap: () {
                      _showLoginMessage(context, 'Please login as a student to access this section.');
                    },
                    color: Colors.deepPurple.shade100,
                    iconColor: Colors.deepPurple,
                  ),
                  _buildRoleCard(
                    context,
                    title: 'Teachers',
                    description: 'Manage classes, mark attendance, and submit grades.',
                    icon: Icons.person_outline,
                    onTap: () {
                      _showLoginMessage(context, 'Please login as a teacher to access this section.');
                    },
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue.shade800,
                  ),
                  _buildRoleCard(
                    context,
                    title: 'Admissions',
                    description: 'Explore our programs and apply for admission.',
                    icon: Icons.how_to_reg_outlined,
                    onTap: () {
                      _showMessage(context, 'Admissions are open! Contact us for more details.');
                    },
                    color: Colors.green.shade100,
                    iconColor: Colors.green.shade800,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'About Us',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Paramount Institute is dedicated to providing quality education and fostering an environment of learning and growth. We offer a wide range of programs designed to equip students with the skills and knowledge needed for a successful future. Our experienced faculty and state-of-the-art facilities ensure a holistic educational experience.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontFamily: 'Oswald'),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for quick contact
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMessage(context, 'Contact us at: info@paramount.edu or call +91-1234567890');
        },
        label: const Text('Contact Us'),
        icon: const Icon(Icons.call),
        backgroundColor: Colors.amberAccent.shade400,
        foregroundColor: Colors.deepPurple.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // Hero section banaya hai jismein image aur text hai
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/homepage.jpg'), // Aapki homepage image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4), // Image par dark overlay
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Paramount Institute',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Journey to Excellence Starts Here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontFamily: 'Oswald',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Role specific cards
  Widget _buildRoleCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required VoidCallback onTap,
        required Color color,
        required Color iconColor,
      }) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                        fontFamily: 'Oswald',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontFamily: 'Oswald'),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation drawer for various options
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Guest User', // Ya login ke baad username dikhao
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                  ),
                ),
                const Text(
                  'info@paramount.edu', // Ya login ke baad email dikhao
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Oswald',
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () => Navigator.popAndPushNamed(context, '/home'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            title: 'Faculty',
            onTap: () => Navigator.popAndPushNamed(context, '/faculty'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.book,
            title: 'Courses',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Courses information coming soon!');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Learn more about Paramount Institute.');
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.login,
            title: 'Login',
            onTap: () {
              Navigator.pop(context);
              _showLoginDialog(context);
            },
            isImportant: true,
          ),
        ],
      ),
    );
  }

  // Drawer item widget
  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, bool isImportant = false}) {
    return ListTile(
      leading: Icon(icon, color: isImportant ? Theme.of(context).colorScheme.secondary : Colors.deepPurple.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
          color: isImportant ? Theme.of(context).colorScheme.secondary : Colors.deepPurple.shade900,
          fontFamily: 'Oswald',
        ),
      ),
      onTap: onTap,
    );
  }

  // Generic message dialog
  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Information', style: TextStyle(fontFamily: 'Oswald')),
          content: Text(message, style: const TextStyle(fontFamily: 'Oswald')),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(dialogContext).primaryColor, fontFamily: 'Oswald')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Login required message dialog
  void _showLoginMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Login Required', style: TextStyle(fontFamily: 'Oswald')),
          content: Text(message, style: const TextStyle(fontFamily: 'Oswald')),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(dialogContext).primaryColor, fontFamily: 'Oswald')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close current dialog
                _showLoginDialog(context); // Open login dialog
              },
              child: const Text('Login Now'),
            ),
          ],
        );
      },
    );
  }

  // Login dialog
  void _showLoginDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(
            child: Text(
              'Login to Paramount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.deepPurple,
                fontFamily: 'Oswald',
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/loginimage.png', // Aapki login image
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person_pin,
                        size: 100,
                        color: Colors.deepPurple.shade300,
                      ); // Fallback icon if image not found
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Dummy login logic
                        if (usernameController.text == 'student' && passwordController.text == 'pass') {
                          Navigator.of(dialogContext).pop(); // Close login dialog
                          Navigator.of(context).pushReplacementNamed('/student_home');
                        } else if (usernameController.text == 'teacher' && passwordController.text == 'pass') {
                          Navigator.of(dialogContext).pop(); // Close login dialog
                          Navigator.of(context).pushReplacementNamed('/teacher_home');
                        } else {
                          _showMessage(dialogContext, 'Invalid credentials. Please try again.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // Full width button
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _showMessage(context, 'Forgot Password functionality is under development.');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.deepPurple.shade400, fontFamily: 'Oswald'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

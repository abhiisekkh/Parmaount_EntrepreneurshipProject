import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/test_data_service.dart';
import '../services/auth_service.dart';
import '../debug/admin_checker.dart';
import '../debug/user_debug_utils.dart';

class ModernAdminHomePage extends StatefulWidget {
  const ModernAdminHomePage({super.key});

  @override
  State<ModernAdminHomePage> createState() => _ModernAdminHomePageState();
}

class _ModernAdminHomePageState extends State<ModernAdminHomePage> {
  final TestDataService _testDataService = TestDataService();

  int get totalStudents => _testDataService.getAllStudents().length;
  int get totalTeachers => _testDataService.getAllFaculty().length;
  int get totalCourses => _testDataService.getAllCourses().length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        actions: [
          // Debug button (remove in production)
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.white),
            onPressed: () => _showDebugInfo(),
            tooltip: 'Debug Admin Status',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                'Manage Students',
                'Add, edit, or remove students',
                Icons.group_rounded,
                const Color(0xFF10B981),
                () => AuthService.navigateToAdminPage(context, '/admin/students'),
              ),
              _buildActionButton(
                'Manage Faculty',
                'Add, edit, or remove teachers',
                Icons.person_add_rounded,
                const Color(0xFF6366F1),
                () => AuthService.navigateToAdminPage(context, '/admin/faculty'),
              ),
              _buildActionButton(
                'Course Management',
                'Manage courses and assignments',
                Icons.book_rounded,
                const Color(0xFFF59E0B),
                () => AuthService.navigateToAdminPage(context, '/admin/courses'),
              ),
              _buildActionButton(
                'Attendance Reports',
                'View and export attendance records',
                Icons.assessment_rounded,
                const Color(0xFF8B5CF6),
                () => AuthService.navigateToAdminPage(context, '/admin/attendance'),
              ),
              _buildActionButton(
                'View Database',
                'Browse all data in the system',
                Icons.storage_rounded,
                const Color(0xFFEF4444),
                () => Navigator.pushNamed(context, '/database_viewer'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome back, Admin! 👋',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening at Paramount today',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Students', '$totalStudents', Icons.group, const Color(0xFF10B981))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Teachers', '$totalTeachers', Icons.person, const Color(0xFF6366F1))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Courses', '$totalCourses', Icons.book, const Color(0xFFF59E0B))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Active', '${totalStudents + totalTeachers}', Icons.trending_up, const Color(0xFF8B5CF6))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDebugInfo() async {
    print('🔧 Debug button pressed - running comprehensive diagnostics...');
    
    final adminResult = await AdminChecker.checkCurrentUserAdmin();
    final adminUsers = await AdminChecker.listAllAdminUsers();
    final userConsistency = await UserDebugUtils.checkCurrentUserConsistency();
    final debugReport = await UserDebugUtils.generateDebugReport();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Comprehensive Debug Info',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 500),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: const Color(0xFF6366F1),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Admin Status'),
                      Tab(text: 'User Consistency'),
                      Tab(text: 'Full Report'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Admin Status Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current User Status:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _buildStatusItem('Authenticated', adminResult['isAuthenticated']),
                              _buildStatusItem('Has Firebase User', adminResult['hasFirebaseUser']),
                              _buildStatusItem('Has Firestore Doc', adminResult['hasFirestoreDoc']),
                              _buildStatusItem('Is Admin', adminResult['isAdmin']),
                              _buildStatusItem('Is Demo Admin', adminResult['isDemoAdmin']),
                              const SizedBox(height: 8),
                              Text('Firestore Role: "${adminResult['firestoreRole']}"'),
                              if (adminResult['firebaseUID'] != null) ...[
                                const SizedBox(height: 8),
                                Text('Firebase UID: ${adminResult['firebaseUID']}'),
                                Text('Firebase Email: ${adminResult['firebaseEmail']}'),
                              ],
                              if ((adminResult['errors'] as List).isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text('❌ Errors:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red)),
                                ...((adminResult['errors'] as List).map((e) => Text('• $e', style: const TextStyle(color: Colors.red)))),
                              ],
                              const SizedBox(height: 16),
                              Text('All Admin Users in DB:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (adminUsers.isEmpty)
                                const Text('No admin users found in Firestore', style: TextStyle(color: Colors.orange))
                              else
                                ...adminUsers.map((user) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('• ${user['name']} (${user['email']})'),
                                )),
                            ],
                          ),
                        ),
                        // User Consistency Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User Consistency Check:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _buildStatusItem('Has Auth User', userConsistency['hasAuthUser']),
                              _buildStatusItem('Has Firestore Doc', userConsistency['hasFirestoreDoc']),
                              _buildStatusItem('Is Consistent', userConsistency['isConsistent']),
                              const SizedBox(height: 8),
                              if (userConsistency['authUserDetails'] != null) ...[
                                Text('Auth User Details:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                Text('UID: ${userConsistency['authUserDetails']['uid']}'),
                                Text('Email: ${userConsistency['authUserDetails']['email']}'),
                                Text('Display Name: ${userConsistency['authUserDetails']['displayName']}'),
                                Text('Email Verified: ${userConsistency['authUserDetails']['emailVerified']}'),
                                const SizedBox(height: 8),
                              ],
                              if (userConsistency['firestoreDetails'] != null) ...[
                                Text('Firestore Details:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                Text('Role: ${userConsistency['firestoreDetails']['role']}'),
                                Text('Name: ${userConsistency['firestoreDetails']['name']}'),
                                Text('Email: ${userConsistency['firestoreDetails']['email']}'),
                                const SizedBox(height: 8),
                              ],
                              if ((userConsistency['issues'] as List).isNotEmpty) ...[
                                Text('Issues Found:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red)),
                                ...((userConsistency['issues'] as List).map((e) => Text('• $e', style: const TextStyle(color: Colors.red)))),
                              ],
                            ],
                          ),
                        ),
                        // Full Report Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Full Debug Report:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  debugReport,
                                  style: GoogleFonts.sourceCodePro(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Test user creation
                try {
                  final testResult = await UserDebugUtils.testUserCreation('test-debug@paramount.edu');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Test Result: ${testResult['success'] ? "SUCCESS" : "FAILED"}'),
                        backgroundColor: testResult['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Test Failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Test Creation',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$label: $status'),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async { // <-- Make this async
                Navigator.pop(context); // Close dialog first

                try {
                  // Sign out from Firebase and clear demo role if applicable
                  await AuthService.signOut(); // <-- ADD THIS LINE

                  if (mounted) { // <-- Check if widget is still mounted
                    // Navigate to auth page and clear history
                    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) { // <-- Check if widget is still mounted
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: $e'),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), // Red color for logout
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
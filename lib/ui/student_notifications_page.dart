import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/student_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  State<StudentNotificationsPage> createState() => _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to load from Firebase
        final firebaseNotifications = await StudentService.getStudentNotifications(user.uid);
        if (firebaseNotifications.isNotEmpty) {
          setState(() {
            notifications = firebaseNotifications;
            isLoading = false;
          });
          return;
        }
      }

      // Fallback to demo data
      final demoNotifications = _getDemoNotifications();
      setState(() {
        notifications = demoNotifications;
        isLoading = false;
      });
    } catch (e) {
      // Fallback to demo data on error
      final demoNotifications = _getDemoNotifications();
      setState(() {
        notifications = demoNotifications;
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDemoNotifications() {
    return [
      {
        'id': '1',
        'title': 'New Assignment Posted',
        'message': 'Physics Lab Report on Pendulum Motion has been assigned. Due in 3 days.',
        'type': 'assignment',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Grade Updated',
        'message': 'Your Chemistry Project grade has been updated. You scored A+ (95/100).',
        'type': 'grade',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'id': '3',
        'title': 'Class Schedule Change',
        'message': 'Tomorrow\'s Mathematics class has been moved from 10:00 AM to 11:00 AM.',
        'type': 'schedule',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'isRead': true,
      },
      {
        'id': '4',
        'title': 'Attendance Alert',
        'message': 'Your Physics attendance is below 75%. Please attend upcoming classes.',
        'type': 'attendance',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
      },
      {
        'id': '5',
        'title': 'Library Book Due',
        'message': 'Your library book "Advanced Physics Concepts" is due tomorrow.',
        'type': 'general',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
      },
      {
        'id': '6',
        'title': 'Exam Schedule Released',
        'message': 'Mid-semester examination schedule has been published. Check your dashboard.',
        'type': 'exam',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
      },
    ];
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'assignment':
        return const Color(0xFF6366F1); // Indigo
      case 'grade':
        return const Color(0xFF10B981); // Green
      case 'schedule':
        return const Color(0xFFF59E0B); // Amber
      case 'attendance':
        return const Color(0xFFEF4444); // Red
      case 'exam':
        return const Color(0xFF8B5CF6); // Purple
      case 'general':
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment_rounded;
      case 'grade':
        return Icons.grade_rounded;
      case 'schedule':
        return Icons.schedule_rounded;
      case 'attendance':
        return Icons.person_rounded;
      case 'exam':
        return Icons.quiz_rounded;
      case 'general':
      default:
        return Icons.notifications_rounded;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? 'general';
    final timestamp = notification['timestamp'] as DateTime;
    
    return FadeInUp(
      duration: Duration(milliseconds: 600 + (index * 100)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFF6366F1).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: isRead ? null : Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getNotificationColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(type),
              color: _getNotificationColor(type),
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification['title'] ?? 'Notification',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (!isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['message'] ?? 'No message available',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(timestamp),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          onTap: () => _markAsRead(notification['id']),
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    final notificationIndex = notifications.indexWhere((n) => n['id'] == notificationId);
    if (notificationIndex != -1 && !notifications[notificationIndex]['isRead']) {
      setState(() {
        notifications[notificationIndex]['isRead'] = true;
      });
      
      // Here you could also update the read status in Firebase
      // await StudentService.markNotificationAsRead(notificationId);
    }
  }

  Future<void> _markAllAsRead() async {
    bool hasUnread = notifications.any((n) => !n['isRead']);
    if (hasUnread) {
      setState(() {
        for (var notification in notifications) {
          notification['isRead'] = true;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n['isRead']).length;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAFAFA), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (unreadCount > 0)
                              Text(
                                '$unreadCount unread notifications',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.done_all_rounded),
                            onPressed: _markAllAsRead,
                            tooltip: 'Mark all as read',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                        ? FadeIn(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    size: 80,
                                    color: const Color(0xFF64748B).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No notifications',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'You\'re all caught up!',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                return _buildNotificationCard(notifications[index], index);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/attendance_service.dart';
import '../services/notification_service.dart';
import '../services/admin_service.dart';

class AppServices {
  // Static service instances
  static final AuthService _authService = AuthService();
  static final DatabaseService _databaseService = DatabaseService();
  static final AttendanceService _attendanceService = AttendanceService();
  static final NotificationService _notificationService = NotificationService();
  static final AdminService _adminService = AdminService();

  // Getters for services (all static methods so can be accessed directly)
  static AuthService get auth => _authService;
  static DatabaseService get database => _databaseService;
  static AttendanceService get attendance => _attendanceService;
  static NotificationService get notification => _notificationService;
  static AdminService get admin => _adminService;
}
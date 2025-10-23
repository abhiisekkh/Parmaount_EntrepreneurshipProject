import 'package:flutter/material.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  // Dummy attendance data for a student
  // In a real app, yeh data backend se fetch hoga
  final List<Map<String, String>> _attendanceRecords = [
    {'date': '2025-08-01', 'course': 'CS301 - Data Structures', 'status': 'Present'},
    {'date': '2025-08-01', 'course': 'MA201 - Linear Algebra', 'status': 'Absent'},
    {'date': '2025-08-02', 'course': 'CS301 - Data Structures', 'status': 'Present'},
    {'date': '2025-08-03', 'course': 'CS302 - Algorithms', 'status': 'Late'},
    {'date': '2025-08-04', 'course': 'CS301 - Data Structures', 'status': 'Present'},
    {'date': '2025-08-05', 'course': 'PH101 - Physics I', 'status': 'Present'},
    {'date': '2025-08-06', 'course': 'CS302 - Algorithms', 'status': 'Present'},
    {'date': '2025-08-07', 'course': 'MA201 - Linear Algebra', 'status': 'Present'},
  ];

  String _selectedFilterCourse = 'All Courses'; // Default filter
  final List<String> _courses = [
    'All Courses',
    'CS301 - Data Structures',
    'CS302 - Algorithms',
    'MA201 - Linear Algebra',
    'PH101 - Physics I',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter attendance records based on selected course
    final filteredRecords = _attendanceRecords.where((record) {
      return _selectedFilterCourse == 'All Courses' ||
          record['course'] == _selectedFilterCourse;
    }).toList();

    // Calculate summary
    int totalClasses = filteredRecords.length;
    int presentCount = filteredRecords.where((r) => r['status'] == 'Present').length;
    int absentCount = filteredRecords.where((r) => r['status'] == 'Absent').length;
    int lateCount = filteredRecords.where((r) => r['status'] == 'Late').length;

    double attendancePercentage = totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Attendance'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFFB993FF), Color(0xFFF5F6FA)],
          ),
        ),
        child: Column(
          children: [
            _buildFilterAndSummary(context, totalClasses, presentCount, absentCount, lateCount, attendancePercentage),
            const Divider(height: 1, thickness: 1),
            // Attendance History List
            Expanded(
              child: filteredRecords.isEmpty
                  ? Center(
                      child: Text(
                        'No attendance records found for selected criteria.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontFamily: 'Oswald'),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return _buildAttendanceRecordCard(context, record);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter and Summary UI
  Widget _buildFilterAndSummary(BuildContext context, int totalClasses, int presentCount, int absentCount, int lateCount, double percentage) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Filter Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedFilterCourse,
            decoration: const InputDecoration(
              labelText: 'Filter by Course',
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: _courses.map((String course) {
              return DropdownMenuItem<String>(
                value: course,
                child: Text(course, style: const TextStyle(fontFamily: 'Oswald')),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFilterCourse = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          // Attendance Summary Card
          Card(
            color: Colors.deepPurple.shade50,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade900,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const Divider(),
                  _buildSummaryRow('Total Classes:', totalClasses.toString(), context),
                  _buildSummaryRow('Present:', presentCount.toString(), context, color: Colors.green),
                  _buildSummaryRow('Absent:', absentCount.toString(), context, color: Colors.red),
                  _buildSummaryRow('Late:', lateCount.toString(), context, color: Colors.orange),
                  const Divider(),
                  _buildSummaryRow(
                    'Overall Percentage:',
                    '${percentage.toStringAsFixed(2)}%',
                    context,
                    isHighlight: true,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for summary rows
  Widget _buildSummaryRow(String label, String value, BuildContext context, {Color? color, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade800,
              fontFamily: 'Oswald',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.deepPurple.shade900,
              fontFamily: 'Oswald',
            ),
          ),
        ],
      ),
    );
  }

  // Individual attendance record card
  Widget _buildAttendanceRecordCard(BuildContext context, Map<String, String> record) {
    Color statusColor;
    IconData statusIcon;

    switch (record['status']) {
      case 'Present':
        statusColor = Colors.green.shade600;
        statusIcon = Icons.check_circle;
        break;
      case 'Absent':
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel;
        break;
      case 'Late':
        statusColor = Colors.orange.shade600;
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = Colors.grey.shade600;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(statusIcon, size: 30, color: statusColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['course']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade900,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Date: ${record['date']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontFamily: 'Oswald'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record['status']!,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Oswald',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

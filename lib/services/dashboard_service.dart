// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get admin logins count
      final adminLogsSnapshot =
          await _firestore.collection('admin_logs').count().get();

      // Get total users count
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .count()
          .get();

      // Get subjects count
      final subjectsSnapshot =
          await _firestore.collection('courses').count().get();

      // Get doctors count
      final doctorsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'faculty')
          .count()
          .get();

      return {
        'adminLogins': adminLogsSnapshot.count,
        'totalUsers': usersSnapshot.count,
        'totalSubjects': subjectsSnapshot.count,
        'totalDoctors': doctorsSnapshot.count,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'adminLogins': 0,
        'totalUsers': 0,
        'totalSubjects': 0,
        'totalDoctors': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final snapshot = await _firestore
          .collection('activity_logs')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'activity': data['description'] ?? 'Unknown activity',
          'timestamp': data['timestamp'] as Timestamp,
        };
      }).toList();
    } catch (e) {
      print('Error fetching recent activity: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopMaterials() async {
    try {
      final snapshot = await _firestore
          .collection('materials')
          .orderBy('downloads', descending: true)
          .limit(3)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['title'] ?? 'Untitled',
          'downloads': data['downloads'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching top materials: $e');
      return [];
    }
  }

  Stream<List<double>> getUserActivityStream() {
    // Get the last 12 months of user activity
    return _firestore.collection('user_logs').snapshots().map((snapshot) {
      List<double> monthlyActivity = List.filled(12, 0);

      for (var doc in snapshot.docs) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        final monthIndex = DateTime.now().month - timestamp.month;
        if (monthIndex >= 0 && monthIndex < 12) {
          monthlyActivity[monthIndex]++;
        }
      }

      return monthlyActivity;
    });
  }

  Future<Map<String, int>> getUserTypeDistribution() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      Map<String, int> distribution = {
        'students': 0,
        'faculty': 0,
        'admin': 0,
        'other': 0,
      };

      for (var doc in snapshot.docs) {
        final role = doc.data()['role'] as String? ?? 'other';
        distribution[role.toLowerCase()] =
            (distribution[role.toLowerCase()] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('Error fetching user distribution: $e');
      return {
        'students': 0,
        'faculty': 0,
        'admin': 0,
        'other': 0,
      };
    }
  }

  Future<Map<String, int>> getMaterialCategories() async {
    try {
      final snapshot = await _firestore.collection('materials').get();
      Map<String, int> categories = {};

      for (var doc in snapshot.docs) {
        final category = doc.data()['category'] as String? ?? 'Uncategorized';
        categories[category] = (categories[category] ?? 0) + 1;
      }

      return categories;
    } catch (e) {
      print('Error fetching material categories: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyActivity() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('user_logs')
          .where('timestamp', isGreaterThan: weekAgo)
          .get();

      Map<String, int> dailyCount = {};

      for (var doc in snapshot.docs) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        final day = DateTime(timestamp.year, timestamp.month, timestamp.day)
            .toString()
            .split(' ')[0];
        dailyCount[day] = (dailyCount[day] ?? 0) + 1;
      }

      return dailyCount.entries
          .map((e) => {'date': e.key, 'count': e.value})
          .toList();
    } catch (e) {
      print('Error fetching weekly activity: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getFacultyStats() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'faculty')
          .get();

      // Count by department
      Map<String, int> departmentStats = {};
      for (var doc in snapshot.docs) {
        final department = doc.data()['department'] as String? ?? 'Other';
        departmentStats[department] = (departmentStats[department] ?? 0) + 1;
      }

      return {
        'totalFaculty': snapshot.docs.length,
        'byDepartment': departmentStats,
      };
    } catch (e) {
      print('Error fetching faculty stats: $e');
      return {
        'totalFaculty': 0,
        'byDepartment': {},
      };
    }
  }

  Future<Map<String, dynamic>> getAdminLoginStats() async {
    try {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      // Get daily login counts for the last week
      final snapshot = await _firestore
          .collection('admin_logs')
          .where('timestamp', isGreaterThan: lastWeek)
          .orderBy('timestamp', descending: true)
          .get();

      // Group by day
      Map<String, int> dailyLogins = {};
      for (var doc in snapshot.docs) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        final day = DateFormat('MM/dd').format(timestamp);
        dailyLogins[day] = (dailyLogins[day] ?? 0) + 1;
      }

      // Get total logins
      final totalLogins =
          await _firestore.collection('admin_logs').count().get();

      return {
        'totalLogins': totalLogins.count,
        'dailyLogins': dailyLogins,
      };
    } catch (e) {
      print('Error fetching admin login stats: $e');
      return {
        'totalLogins': 0,
        'dailyLogins': {},
      };
    }
  }

  getAdminDashboardTheme() {}
}

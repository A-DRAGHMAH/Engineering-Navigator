// ignore_for_file: avoid_print

import 'dart:io';
// import 'dart:developer';

import 'package:aaup/models/course_model.dart';
import 'package:aaup/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
// ignore: unused_shown_name
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:aaup/services/appwrite_service.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/educational_program.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class AdminService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Admin Authentication
  static Future<bool> verifyAdmin(String email, String password) async {
    try {
      debugPrint('Attempting admin login with email: $email');

      // First verify if the email is in admins collection
      final adminQuery = await _db
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        debugPrint('Email not found in admins collection');
        return false;
      }

      // Then attempt Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        debugPrint('Login failed: No user returned');
        return false;
      }

      // Verify admin status
      final adminDoc = await _db.collection('admins').doc(user.uid).get();
      if (!adminDoc.exists) {
        // Create admin document if it doesn't exist but email was verified
        await _db.collection('admins').doc(user.uid).set({
          'email': email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'uid': user.uid,
          'lastLogin': FieldValue.serverTimestamp(),
        });
        debugPrint('Created admin document');
      } else {
        // Update last login
        await _db.collection('admins').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('Admin login successful: ${user.uid}');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Admin verification error: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
    debugPrint('Admin logged out');
  }

  // Get current admin
  static User? get currentAdmin => _auth.currentUser;

  // Check if user is logged in and is admin
  static Future<bool> isAdminLoggedIn() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final adminDoc = await _db.collection('admins').doc(user.uid).get();
    return adminDoc.exists;
  }

  // Add this method to AdminService class
  static Future<void> sendNotification(String message, String priority) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      await _db.collection('notifications').add({
        'message': message,
        'priority': priority,
        'timestamp': FieldValue.serverTimestamp(),
        'adminId': user.uid,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
      throw Exception('Failed to send notification: $e');
    }
  }

  // Add these methods to AdminService
  static Future<String?> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  static Future<void> addFacultyMember({
    required String name,
    required String department,
    required String officeLocation,
    required String phoneNumber,
    required String email,
    required String bio,
    String? title,
    String? role,
    String? officeHours,
    File? imageFile,
    XFile? webImageFile,
  }) async {
    try {
      String? imageUrl;

      // Handle image upload for both web and mobile
      if (webImageFile != null || imageFile != null) {
        try {
          final fileName =
              'faculty_${DateTime.now().millisecondsSinceEpoch}.${kIsWeb ? webImageFile!.name.split('.').last : imageFile!.path.split('.').last}';

          dynamic fileToUpload;
          if (kIsWeb) {
            fileToUpload = webImageFile;
          } else {
            fileToUpload = imageFile;
          }

          final fileId =
              await AppwriteService.uploadTeacherPhoto(fileToUpload, fileName);
          imageUrl = await AppwriteService.getTeacherPhotoUrl(fileId);
          debugPrint('Image uploaded to Appwrite: $imageUrl');
        } catch (e) {
          debugPrint('Error uploading image to Appwrite: $e');
          imageUrl = null;
        }
      }

      // Create faculty member document
      await _db.collection('faculty').add({
        'name': name,
        'department': department,
        'officeLocation': officeLocation,
        'phoneNumber': phoneNumber,
        'email': email,
        'bio': bio,
        'imageUrl': imageUrl,
        'title': title ?? '',
        'role': role ?? '',
        'officeHours': officeHours ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Faculty member added successfully with image: $imageUrl');
    } catch (e) {
      debugPrint('Error adding faculty member: $e');
      throw Exception('Failed to add faculty member: $e');
    }
  }

  static Stream<QuerySnapshot> getFacultyStream() {
    return _db.collection('faculty').orderBy('name').snapshots();
  }

  // Add this method to AdminService class
  static Future<void> deleteFacultyMember(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      await _db.collection('faculty').doc(id).delete();
      debugPrint('Faculty member deleted successfully');
    } catch (e) {
      debugPrint('Error deleting faculty member: $e');
      throw Exception('Failed to delete faculty member: $e');
    }
  }

  // Add these methods to AdminService class
  static Future<void> addUser({
    required String email,
    required String role,
  }) async {
    try {
      await _db.collection('users').add({
        'email': email,
        'role': role,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding user: $e');
      throw Exception('Failed to add user: $e');
    }
  }

  static Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _db.collection('users').doc(userId).update({
        'status': isActive ? 'active' : 'inactive',
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
      throw Exception('Failed to update user status: $e');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // Add these methods for settings management
  static Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      await _db.collection('settings').doc('app_settings').set(
            settings,
            SetOptions(merge: true),
          );
      debugPrint('Settings updated successfully');
    } catch (e) {
      debugPrint('Error updating settings: $e');
      throw Exception('Failed to update settings: $e');
    }
  }

  static Stream<DocumentSnapshot> getSettingsStream() {
    return _db.collection('settings').doc('app_settings').snapshots();
  }

  static Future<void> uploadMap({
    required String name,
    required File file,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storageRef = _storage.ref().child('maps/$fileName');

      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();

      await _db.collection('maps').add({
        'name': name,
        'url': url,
        'uploadedBy': user.uid,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error uploading map: $e');
      throw Exception('Failed to upload map: $e');
    }
  }

  static Future<void> addEvent(EventModel event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      await _db.collection('events').add({
        'title': event.title,
        'type': event.type,
        'startTime': Timestamp.fromDate(event.startTime),
        'endTime': Timestamp.fromDate(event.endTime),
        'location': event.location,
        'description': event.description,
        'isPublic': true,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding event: $e');
      throw Exception('Failed to add event: $e');
    }
  }

  // Add method to get events stream
  static Stream<QuerySnapshot> getEventsStream() {
    return _db
        .collection('events')
        .orderBy('startTime', descending: false)
        .snapshots();
  }

  // Add method to get public events stream
  static Stream<QuerySnapshot> getPublicEventsStream() {
    return _db
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .orderBy('startTime', descending: false)
        .snapshots();
  }

  // Add this method for web file uploads
  static Future<void> uploadMapWeb({
    required String name,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      final storageRef = _storage
          .ref()
          .child('maps/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await storageRef.putData(bytes);
      final url = await storageRef.getDownloadURL();

      await _db.collection('maps').add({
        'name': name,
        'url': url,
        'uploadedBy': user.uid,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error uploading map: $e');
      throw Exception('Failed to upload map: $e');
    }
  }

  static Future<void> addStudyMaterial({
    required String title,
    required String description,
    required String department,
    String? course,
    required String year,
    required String semester,
    required String fileType,
    required String url,
    required List<String> tags,
    required bool isPublic,
    String? thumbnailUrl,
    required int icon,
    required String name,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      await _db.collection('study_materials').add({
        'title': title,
        'description': description,
        'department': department,
        'course': course,
        'year': year,
        'semester': semester,
        'fileType': fileType,
        'url': url,
        'uploadedBy': user.uid,
        'uploadedAt': FieldValue.serverTimestamp(),
        'downloads': 0,
        'tags': tags,
        'isPublic': isPublic,
        'thumbnailUrl': thumbnailUrl,
      });
    } catch (e) {
      debugPrint('Error adding study material: $e');
      throw Exception('Failed to add study material: $e');
    }
  }

  static deleteStudyMaterial(String id) {}

  static Future<void> createStudyMaterialsIndex() async {
    try {
      // This query will trigger the index creation
      await FirebaseFirestore.instance
          .collection('study_materials')
          .where('department', isEqualTo: 'Computer Engineering')
          .where('isPublic', isEqualTo: true)
          .orderBy('uploadedAt', descending: true)
          .limit(1)
          .get();
    } catch (e) {
      debugPrint('Creating study materials index...');
    }
  }

  static Future<void> addCourse(CourseModel course) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated as admin');
      }

      await _db.collection('courses').add({
        ...course.toMap(),
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding course: $e');
      throw Exception('Failed to add course: $e');
    }
  }

  static Future<void> deleteCourse(String courseId) async {
    try {
      await _db.collection('courses').doc(courseId).delete();
    } catch (e) {
      logger.e('Error deleting course: $e');
      rethrow; // Rethrow the error for handling in the UI
    }
  }

  static Future<void> createCoursesIndexes() async {
    try {
      // This will trigger index creation
      await FirebaseFirestore.instance
          .collection('courses')
          .where('department', isEqualTo: 'Computer Engineering')
          .orderBy('name')
          .limit(1)
          .get();
    } catch (e) {
      debugPrint('Creating courses index...');
    }
  }

  static Future<void> createChatIndex() async {
    try {
      // Create index for chat messages
      await FirebaseFirestore.instance
          .collection('chat_messages')
          .where('sessionId', isEqualTo: 'test')
          .orderBy('timestamp')
          .limit(1)
          .get();
    } catch (e) {
      debugPrint('Creating chat index...');
    }
  }

  static Future<void> incrementDownloadCount(String materialId) async {
    try {
      await _db.collection('study_materials').doc(materialId).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error updating download count: $e');
      // Don't throw error to avoid interrupting download
    }
  }

  static Future<void> deleteNotification(String id) async {
    try {
      await _db.collection('notifications').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      throw Exception('Failed to delete notification');
    }
  }

  static Future<void> deleteReadNotifications() async {
    try {
      final batch = _db.batch();
      final readNotifications = await _db
          .collection('notifications')
          .where('isRead', isEqualTo: true)
          .get();

      for (var doc in readNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting read notifications: $e');
      throw Exception('Failed to delete read notifications');
    }
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final doc = await _db.collection('settings').doc('app_settings').get();
    return doc.data() ?? {};
  }

  static Future<void> backupDatabase() async {
    try {
      // Implement your backup logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      debugPrint('Database backup completed');
    } catch (e) {
      debugPrint('Error during backup: $e');
      throw Exception('Failed to backup database');
    }
  }

  static Future<void> clearCache() async {
    try {
      // Implement your cache clearing logic here
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      throw Exception('Failed to clear cache');
    }
  }

  static Future<List<Map<String, dynamic>>> getAccessLogs() async {
    try {
      final logs = await _db
          .collection('access_logs')
          .orderBy('timestamp', descending: true)
          .get();
      return logs.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting access logs: $e');
      throw Exception('Failed to get access logs');
    }
  }

  static Future<void> resetPassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        debugPrint('Password updated successfully');
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      debugPrint('Error resetting password: $e');
      throw Exception('Failed to reset password');
    }
  }

  static Future<void> createEventIndexes() async {
    try {
      // This will trigger index creation
      await FirebaseFirestore.instance
          .collection('events')
          .where('isPublic', isEqualTo: true)
          .orderBy('startTime', descending: false)
          .limit(1)
          .get();
    } catch (e) {
      debugPrint('Creating events index...');
    }
  }

  static Future<void> addInitialFacultyMembers() async {
    final List<Map<String, String>> facultyMembers = [
      {
        'name': 'Dr. Mohannad Jazzar',
        'title': 'Dr.',
        'role': 'Dean',
        'department': 'Computer Engineering',
        'officeLocation': 'Engineering Building, Dean\'s Office',
        'email': 'mjazzar@aaup.edu',
        'phoneNumber': '+970 4 2418888',
        'bio': 'Dean of Faculty of Engineering and Information Technology',
        'officeHours': 'Sunday, Tuesday 10:00-12:00',
      },
      {
        'name': 'Dr. Samer Arandi',
        'title': 'Dr.',
        'role': 'Head of Department',
        'department': 'Computer Engineering',
        'officeLocation': 'Engineering Building',
        'email': 'sarandi@aaup.edu',
        'phoneNumber': '+970 4 2418888',
        'bio': 'Head of Computer Engineering Department',
        'officeHours': 'Monday, Wednesday 11:00-13:00',
      },
      {
        'name': 'Dr. Nael Salman',
        'title': 'Dr.',
        'role': 'Professor',
        'department': 'Computer Engineering',
        'officeLocation': 'Engineering Building',
        'email': 'nsalman@aaup.edu',
        'phoneNumber': '+970 4 2418888',
        'bio': 'Professor at Computer Engineering Department',
        'officeHours': 'Sunday, Tuesday 12:00-14:00',
      },
      // Add more faculty members here...
    ];

    for (var member in facultyMembers) {
      try {
        await addFacultyMember(
          name: member['name']!,
          title: member['title'],
          role: member['role'],
          department: member['department']!,
          officeLocation: member['officeLocation']!,
          email: member['email']!,
          phoneNumber: member['phoneNumber']!,
          bio: member['bio']!,
          officeHours: member['officeHours'],
        );
        debugPrint('Added faculty member: ${member['name']}');
      } catch (e) {
        debugPrint('Error adding faculty member ${member['name']}: $e');
      }
    }
  }

  static Future<void> login() async {
    try {
      // Add this logging code
      await FirebaseFirestore.instance.collection('admin_logs').add({
        'timestamp': Timestamp.now(),
        'action': 'login',
        'status': 'success',
      });

      // Your existing login code...
    } catch (e) {
      rethrow;
    }
  }

  // Add these new methods to AdminService class

  static Future<void> uploadHallVideo({
    required String title,
    required String description,
    required dynamic videoFile,
    required String hallNumber,
    required String floor,
    required String locationDescription,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload to Appwrite
      final fileId = await AppwriteService.uploadVideo(
        videoFile.path,
        'hall_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      // Create document in Appwrite
      await AppwriteService.createHallVideo(
        title: title,
        description: description,
        fileId: fileId,
        hallNumber: hallNumber,
        floor: floor,
        locationDescription: locationDescription,
      );
    } catch (e) {
      debugPrint('Error uploading hall video: $e');
      rethrow;
    }
  }

  // Get videos stream with proper filtering and sorting
  static Stream<QuerySnapshot> getHallVideosStream() {
    try {
      return _db
          .collection('hall_videos')
          .where('status', isEqualTo: 'active')
          .snapshots();
    } catch (e) {
      debugPrint('Error getting hall videos stream: $e');
      rethrow;
    }
  }

  // Get admin videos stream
  static Stream<QuerySnapshot> getAdminHallVideosStream() {
    try {
      return _db
          .collection('hall_videos')
          .where('status', isEqualTo: 'active')
          .snapshots();
    } catch (e) {
      debugPrint('Error getting admin hall videos stream: $e');
      rethrow;
    }
  }

  // Soft delete video
  static Future<void> deleteHallVideo(String id) async {
    try {
      final doc = await _db.collection('hall_videos').doc(id).get();
      if (!doc.exists) throw Exception('Video not found');

      // Update status instead of deleting
      await _db.collection('hall_videos').doc(id).update({
        'status': 'deleted',
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      debugPrint('Video marked as deleted: $id');
    } catch (e) {
      debugPrint('Error deleting hall video: $e');
      throw Exception('Failed to delete hall video: $e');
    }
  }

  static List<String> getAvailableFloors() {
    return [
      'All Floors',
      'Ground Floor',
      'First Floor',
      'Second Floor',
      'Third Floor',
    ];
  }

  static Future<void> updateTeacherPhoto(
      String teacherId, dynamic photoFile, String fileName) async {
    try {
      // Upload photo to Appwrite
      final fileId =
          await AppwriteService.uploadTeacherPhoto(photoFile, fileName);

      // Update teacher document with new photo ID
      await _db.collection('teachers').doc(teacherId).update({
        'photoId': fileId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('Teacher photo updated successfully');
    } catch (e) {
      debugPrint('Error updating teacher photo: $e');
      rethrow;
    }
  }

  static Future<String?> getTeacherPhotoUrl(String teacherId) async {
    try {
      final doc = await _db.collection('teachers').doc(teacherId).get();
      if (!doc.exists) return null;

      final photoId = doc.data()?['photoId'];
      if (photoId == null) return null;

      return await AppwriteService.getTeacherPhotoUrl(photoId);
    } catch (e) {
      debugPrint('Error getting teacher photo URL: $e');
      return null;
    }
  }

  // Method to fetch educational programs
  static Future<List<EducationalProgram>> getEducationalPrograms() async {
    try {
      final snapshot = await _db.collection('educational_programs').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EducationalProgram(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          specialty: data['specialty'] ?? '',
          duration: data['duration'] ?? '',
          level: data['level'] ?? '',
          language: data['language'] ?? '',
          modules: List<String>.from(data['modules'] ?? []),
          lessons: List<String>.from(data['lessons'] ?? []),
          resources: List<String>.from(data['resources'] ?? []),
          assignments: List<String>.from(data['assignments'] ?? []),
          instructorName: data['instructorName'] ?? '',
          instructorQualifications: data['instructorQualifications'] ?? '',
          contactInfo: data['contactInfo'] ?? '',
          startDate:
              (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          enrollmentLimit: (data['enrollmentLimit'] as int?) ?? 0,
          price: (data['price'] as double?) ?? 0.0,
          status: data['status'] ?? '',
        );
      }).toList();
    } catch (e) {
      logger.e('Error fetching educational programs: $e');
      return [];
    }
  }

  // Method to add a new educational program
  static Future<void> addEducationalProgram(EducationalProgram program) async {
    try {
      await _db.collection('educational_programs').add({
        'title': program.title,
        'description': program.description,
        'specialty': program.specialty,
        'duration': program.duration,
        'level': program.level,
        'language': program.language,
        'modules': program.modules,
        'lessons': program.lessons,
        'resources': program.resources,
        'assignments': program.assignments,
        'instructorName': program.instructorName,
        'instructorQualifications': program.instructorQualifications,
        'contactInfo': program.contactInfo,
        'startDate': Timestamp.fromDate(program.startDate),
        'endDate': Timestamp.fromDate(program.endDate),
        'enrollmentLimit': program.enrollmentLimit,
        'price': program.price,
        'status': program.status,
      });
    } catch (e) {
      logger.e('Error adding educational program: $e');
    }
  }

  static Future<void> deleteEducationalProgram(String programId) async {
    try {
      // Advanced admin permission check
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Not logged in');
      }

      // Direct check for user in admins collection
      final adminQuery = await FirebaseFirestore.instance
          .collection('admins')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        throw Exception('Unauthorized access');
      }

      // Delete educational program with additional verification
      final programRef = FirebaseFirestore.instance
          .collection('educational_programs')
          .doc(programId);

      // Check program existence before deletion
      final programDoc = await programRef.get();
      if (!programDoc.exists) {
        throw Exception('Program does not exist');
      }

      // Delete the program
      await programRef.delete();

      // Log the deletion
      logger.i('Educational program deleted: $programId');
    } catch (e, stackTrace) {
      // Detailed error logging
      logger.e('Error deleting educational program', e, stackTrace);
      rethrow;
    }
  }

  // إضافة تقييم للبرنامج
  static Future<void> addProgramRating({
    required String programId,
    required String userId,
    required double ratingValue,
    String comment = '',
  }) async {
    try {
      // توليد معرف فريد للمستخدم المجهول إذا كان المعرف فارغًا
      if (userId.isEmpty) {
        userId = 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      }

      final programRef = _db.collection('educational_programs').doc(programId);

      final programDoc = await programRef.get();
      if (!programDoc.exists) {
        throw Exception('Program not found');
      }

      final currentData = programDoc.data() ?? {};
      final currentRatings = currentData['ratings'] as List? ?? [];

      final existingRatingIndex =
          currentRatings.indexWhere((rating) => rating['userId'] == userId);

      final rating = {
        'userId': userId,
        'value': ratingValue,
        'comment': comment.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      Map<String, dynamic> updateData = {};

      if (existingRatingIndex != -1) {
        currentRatings[existingRatingIndex] = rating;
        updateData['ratings'] = currentRatings;
      } else {
        updateData['ratings'] = FieldValue.arrayUnion([rating]);
      }

      final allRatings = existingRatingIndex != -1
          ? currentRatings
          : [...currentRatings, rating];

      // ignore: avoid_types_as_parameter_names
      final averageRating = allRatings.fold(0.0, (sum, r) => sum + r['value']) /
          allRatings.length;
      updateData['averageRating'] = averageRating;

      await programRef.update(updateData);
    } catch (e) {
      print('❌ Error in addProgramRating: $e');
      rethrow;
    }
  }

  // حذف تقييم
  static Future<void> deleteProgramRating({
    required String programId,
    required Rating rating,
  }) async {
    try {
      final programRef = _db.collection('educational_programs').doc(programId);

      await programRef.update({
        'ratings': FieldValue.arrayRemove([rating.toMap()]),
      });
    } catch (e) {
      logger.e('Error deleting program rating: $e');
      rethrow;
    }
  }

  static Future<List<EducationalProgram>>
      getEducationalProgramsWithRatings() async {
    try {
      final snapshot = await _db.collection('educational_programs').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EducationalProgram(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          specialty: data['specialty'] ?? '',
          duration: data['duration'] ?? '',
          level: data['level'] ?? '',
          language: data['language'] ?? '',
          modules: List<String>.from(data['modules'] ?? []),
          lessons: List<String>.from(data['lessons'] ?? []),
          resources: List<String>.from(data['resources'] ?? []),
          assignments: List<String>.from(data['assignments'] ?? []),
          instructorName: data['instructorName'] ?? '',
          instructorQualifications: data['instructorQualifications'] ?? '',
          contactInfo: data['contactInfo'] ?? '',
          startDate:
              (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          enrollmentLimit: (data['enrollmentLimit'] as int?) ?? 0,
          price: (data['price'] as double?) ?? 0.0,
          status: data['status'] ?? '',
          registrationLink: data['registrationLink'],
          // Explicitly parse ratings
          ratings: data['ratings'] != null
              ? List<Rating>.from((data['ratings'] as List).map((ratingData) =>
                  Rating.fromMap(ratingData as Map<String, dynamic>)))
              : [],
          // Calculate average rating
          averageRating: data['ratings'] != null
              ? _calculateAverageRating((data['ratings'] as List)
                  .map((r) => r['value'] as double)
                  .toList())
              : 0.0,
        );
      }).toList();
    } catch (e) {
      logger.e('Error fetching educational programs with ratings: $e');
      return [];
    }
  }

  // Helper method to calculate average rating
  static double _calculateAverageRating(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}

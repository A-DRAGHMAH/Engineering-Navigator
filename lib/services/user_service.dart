import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/educational_program.dart';
import 'package:logger/logger.dart';
import '../models/course_model.dart';

final Logger logger = Logger();

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch educational programs
  static Future<List<EducationalProgram>> getEducationalPrograms() async {
    try {
      final snapshot =
          await _firestore.collection('educational_programs').get();
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

  static Future<List<CourseModel>> getCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.docs.map((doc) => CourseModel.fromDocument(doc)).toList();
    } catch (e) {
      logger.e('Error fetching courses: $e');
      return [];
    }
  }

  static Future<String?> getRegistrationLink() async {
    try {
      final snapshot = await _firestore
          .collection('app_settings')
          .doc('course_registration')
          .get();

      return snapshot.data()?['registration_link'];
    } catch (e) {
      logger.e('Error fetching registration link: $e');
      return null;
    }
  }
}

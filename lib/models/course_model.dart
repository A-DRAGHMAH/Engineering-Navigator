import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String code;
  final String name;
  final String department;
  final String description;
  final int creditHours;
  final List<String> prerequisites;
  final String year;
  final String semester;
  final String? registrationLink;
  final String? specialization;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.description,
    required this.creditHours,
    required this.prerequisites,
    required this.year,
    required this.semester,
    this.registrationLink,
    this.specialization,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'department': department,
      'description': description,
      'creditHours': creditHours,
      'prerequisites': prerequisites,
      'year': year,
      'semester': semester,
      'registrationLink': registrationLink,
      'specialization': specialization,
    };
  }

  // Method to create a CourseModel from a Firestore document
  factory CourseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      description: data['description'] ?? '',
      creditHours: data['creditHours'] ?? 0,
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      year: data['year'] ?? '',
      semester: data['semester'] ?? '',
      registrationLink: data['registrationLink'],
      specialization: data['specialization'],
    );
  }
}

// Engineering Departments at AAUP
const engineeringDepartments = [
  'Department of Architecture',
  'Department of Biomedical Engineering',
  'Department of Civil Engineering',
  'Department of Computer Systems Engineering',
  'Department of Cybersecurity Engineering',
  'Department of Electrical Engineering',
  'Department of Mechatronics Engineering',
  'Department of Communications Engineering',
];

// Academic Years
const academicYears = [
  '1st Year',
  '2nd Year',
  '3rd Year',
  '4th Year',
  '5th Year',
];

// Semesters
const semesters = [
  'First Semester',
  'Second Semester',
  'Summer Semester',
];

// Sample courses for each department
final sampleCourses = {
  'Computer Engineering': [
    'Programming Fundamentals',
    'Digital Logic Design',
    'Data Structures',
    'Computer Architecture',
    'Operating Systems',
    'Computer Networks',
    'Database Systems',
    'Software Engineering',
    'Embedded Systems',
    'Machine Learning',
  ],
  'Civil Engineering': [
    'Structural Analysis',
    'Soil Mechanics',
    'Construction Materials',
    'Fluid Mechanics',
    'Steel Design',
    'Concrete Design',
    'Transportation Engineering',
    'Environmental Engineering',
    'Foundation Engineering',
    'Construction Management',
  ],
  // Add other departments' courses...
}; 
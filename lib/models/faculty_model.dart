class FacultyMember {
  final String id;
  final String name;
  final String department;
  final String specialization;
  final String academicRank; // Professor, Associate Prof., etc.
  final String officeLocation;
  final String officeHours;
  final String phoneNumber;
  final String email;
  final String bio;
  final String imageUrl;
  final List<String> researchInterests;
  final List<String> courses;
  final String education; // Highest degree, university
  final String website;
  final bool isHeadOfDepartment;

  FacultyMember({
    required this.id,
    required this.name,
    required this.department,
    required this.specialization,
    required this.academicRank,
    required this.officeLocation,
    required this.officeHours,
    required this.phoneNumber,
    required this.email,
    required this.bio,
    required this.imageUrl,
    required this.researchInterests,
    required this.courses,
    required this.education,
    this.website = '',
    this.isHeadOfDepartment = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'specialization': specialization,
      'academicRank': academicRank,
      'officeLocation': officeLocation,
      'officeHours': officeHours,
      'phoneNumber': phoneNumber,
      'email': email,
      'bio': bio,
      'imageUrl': imageUrl,
      'researchInterests': researchInterests,
      'courses': courses,
      'education': education,
      'website': website,
      'isHeadOfDepartment': isHeadOfDepartment,
    };
  }
}

// AAUP Engineering Departments and Specializations
const engineeringDepartments = {
  'Computer Engineering': [
    'Computer Networks and Security',
    'Software Engineering',
    'Artificial Intelligence',
    'Computer Architecture',
    'Embedded Systems',
  ],
  'Civil Engineering': [
    'Structural Engineering',
    'Geotechnical Engineering',
    'Transportation Engineering',
    'Environmental Engineering',
    'Construction Management',
  ],
  'Architectural Engineering': [
    'Architectural Design',
    'Urban Planning',
    'Sustainable Architecture',
    'Interior Design',
  ],
  'Mechanical Engineering': [
    'Thermal Sciences',
    'Mechanics and Design',
    'Manufacturing',
    'Automotive Engineering',
  ],
  'Mechatronics Engineering': [
    'Robotics',
    'Control Systems',
    'Automation',
    'Industrial Electronics',
  ],
  'Chemical Engineering': [
    'Process Engineering',
    'Materials Engineering',
    'Environmental Engineering',
  ],
  'Industrial Engineering': [
    'Operations Research',
    'Quality Engineering',
    'Manufacturing Systems',
    'Engineering Management',
  ],
  'Communications Engineering': [
    'Telecommunications',
    'Signal Processing',
    'Wireless Communications',
    'Digital Communications',
  ],
};

// Academic Ranks
const academicRanks = [
  'Professor',
  'Associate Professor',
  'Assistant Professor',
  'Lecturer',
  'Teaching Assistant',
]; 
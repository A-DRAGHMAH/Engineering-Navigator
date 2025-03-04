class FacultyMemberModel {
  final String id;
  final String name;
  final String title;
  final String role;
  final String department;
  final String officeLocation;
  final String phoneNumber;
  final String email;
  final String bio;
  final String? imageUrl;
  final String officeHours;

  FacultyMemberModel({
    required this.id,
    required this.name,
    required this.title,
    required this.role,
    required this.department,
    required this.officeLocation,
    required this.phoneNumber,
    required this.email,
    required this.bio,
    this.imageUrl,
    required this.officeHours,
  });

  static const roles = ['dean', 'doctor', 'secretary'];

  static const departments = [
    'Dean Office',
    'Computer Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
    'Architectural Engineering',
    'Communications Engineering',
    'Chemical Engineering',
    'Industrial Engineering',
  ];
}

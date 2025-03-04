class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String department;
  final String? course;
  final String year;
  final String semester;
  final String fileType; // pdf, doc, video, etc.
  final String url;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int downloads;
  final List<String> tags;
  final bool isPublic;
  final String? thumbnailUrl;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    this.course,
    required this.year,
    required this.semester,
    required this.fileType,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.downloads,
    required this.tags,
    required this.isPublic,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'course': course,
      'year': year,
      'semester': semester,
      'fileType': fileType,
      'url': url,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'downloads': downloads,
      'tags': tags,
      'isPublic': isPublic,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

// File type constants
const materialTypes = [
  'PDF',
  'Document',
  'Video',
  'Presentation',
  'Image',
  'Code',
  'Other'
];

// Semesters
const materialSemesters = [
  'First Semester',
  'Second Semester',
  'Summer Semester',
]; 
// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../models/course_model.dart';
import '../../services/admin_service.dart';

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  get department => null;
  final _registrationLinkController = TextEditingController();

  get value => null;

  @override
  void initState() {
    super.initState();
    _loadCourses(); // Load courses when the page initializes
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: engineeringDepartments.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course Management'),
          bottom: TabBar(
            isScrollable: true,
            tabs:
                engineeringDepartments.map((dept) => Tab(text: dept)).toList(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Course'),
                onPressed: () => _showAddCourseDialog(context),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: _showRegistrationLinkDialog,
              tooltip: 'Manage Registration Link',
            ),
          ],
        ),
        body: TabBarView(
          children: engineeringDepartments.map((dept) {
            return _DepartmentCoursesView(
              department: dept,
              onDelete: _deleteCourse,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final registrationLinkController = TextEditingController();

    String? selectedYear;
    String? selectedSemester;
    String? selectedSpecialization;
    String? selectedDepartment;
    int creditHours = 3;

    // Updated specializations list
    final specializations = [
      'Architecture',
      'Biomedical Engineering',
      'Civil Engineering',
      'Computer Systems Engineering',
      'Cybersecurity Engineering',
      'Electrical Engineering',
      'Mechatronics Engineering',
      'Communications Engineering',
    ];

    bool isValidUrl(String url) {
      if (url.isEmpty) return true; // Allow empty URL
      final urlPattern = RegExp(
        r'^(https?:\/\/)?' // protocol
        r'(([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}' // domain name
        r'(\.[a-z]{2,})?' // TLD
        r'(:\d+)?' // port
        r'(\/[-a-z\d%_.~+]*)*' // path
        r'(\?[;&a-z\d%_.~+=-]*)?' // query string
        r'(#[-a-z\d_]*)?$',
        caseSensitive: false,
      );
      return urlPattern.hasMatch(url);
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Course'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Course Code
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    hintText: 'e.g., CS101',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Course code is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Course Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    hintText: 'Enter full course name',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Course name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Course Description',
                    hintText: 'Enter course description',
                  ),
                  maxLines: 2,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Course description is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Department Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Department'),
                  items: engineeringDepartments
                      .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                      .toList(),
                  onChanged: (value) => selectedDepartment = value,
                  validator: (value) =>
                      value == null ? 'Select a department' : null,
                ),
                const SizedBox(height: 16),

                // Specialization Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Specialization'),
                  items: specializations
                      .map((spec) => DropdownMenuItem(
                            value: spec,
                            child: Text(spec),
                          ))
                      .toList(),
                  onChanged: (value) => selectedSpecialization = value,
                  validator: (value) =>
                      value == null ? 'Select a specialization' : null,
                ),
                const SizedBox(height: 16),

                // Year Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Academic Year',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Year'),
                  items: academicYears
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          ))
                      .toList(),
                  onChanged: (value) => selectedYear = value,
                  validator: (value) =>
                      value == null ? 'Select an academic year' : null,
                ),
                const SizedBox(height: 16),

                // Semester Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Semester'),
                  items: semesters
                      .map((sem) => DropdownMenuItem(
                            value: sem,
                            child: Text(sem),
                          ))
                      .toList(),
                  onChanged: (value) => selectedSemester = value,
                  validator: (value) =>
                      value == null ? 'Select a semester' : null,
                ),
                const SizedBox(height: 16),

                // Registration Link
                TextFormField(
                  controller: registrationLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Link',
                    hintText: 'Optional: Enter course registration URL',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return isValidUrl(value) ? null : 'Enter a valid URL';
                    }
                    return null; // Optional field
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Validate all form fields
              if (formKey.currentState?.validate() ?? false) {
                try {
                  // Ensure all required fields are not null
                  if (selectedDepartment == null ||
                      selectedSpecialization == null ||
                      selectedYear == null ||
                      selectedSemester == null) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create CourseModel
                  final newCourse = CourseModel(
                    id: '', // Firestore will generate an ID
                    code: codeController.text.trim(),
                    name: nameController.text.trim(),
                    department: selectedDepartment!,
                    description: descController.text.trim(),
                    creditHours: creditHours,
                    prerequisites: [], // You can add prerequisite logic later
                    year: selectedYear!,
                    semester: selectedSemester!,
                    registrationLink: registrationLinkController.text.trim(),
                    specialization: selectedSpecialization!,
                  );

                  // Add course using AdminService
                  await AdminService.addCourse(newCourse);

                  // Optional: Save registration link to app settings
                  if (registrationLinkController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('app_settings')
                        .doc('course_registration')
                        .set({
                      'registration_link':
                          registrationLinkController.text.trim(),
                      'updated_at': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                  }

                  // Close dialog and show success message
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // ignore: avoid_print
                  print('Error adding course: $e'); // Log the error
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error adding course: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Course'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      await AdminService.deleteCourse(courseId);
      if (!mounted) return; // Guard against async gap
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Course deleted successfully')),
      );
      _loadCourses(); // Refresh the list after deletion
    } catch (e) {
      if (!mounted) return; // Guard against async gap
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error deleting course: $e')),
      );
    }
  }

  Future<void> _loadCourses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      if (!mounted) return; // Add mounted check
      setState(() {
        snapshot.docs.map((doc) => CourseModel.fromDocument(doc)).toList();
      });
    } catch (e) {
      if (!mounted) return; // Add mounted check
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e')),
      );
    }
  }

  void _showRegistrationLinkDialog() {
    showDialog(
      context: context as BuildContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Course Registration Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _registrationLinkController,
              decoration: const InputDecoration(
                labelText: 'Registration Link',
                hintText: 'Enter full URL for course registration',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveRegistrationLink(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRegistrationLink(BuildContext dialogContext) async {
    final link = _registrationLinkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(content: Text('Please enter a valid link')),
      );
      return;
    }

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('course_registration')
          .set({
        'registration_link': link,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Registration link updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error saving link: $e')),
      );
    }
  }

  @override
  void dispose() {
    _registrationLinkController.dispose();
    super.dispose();
  }
}

class _DepartmentCoursesView extends StatelessWidget {
  final String department;
  final Function(String) onDelete;

  const _DepartmentCoursesView({
    required this.department,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('department', isEqualTo: department)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data!.docs;

        courses.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          return aData['name'].toString().compareTo(bData['name'].toString());
        });

        if (courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No courses added for $department',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final courseModel = CourseModel.fromDocument(course);
            return _CourseCard(
              course: courseModel,
              courseId: course.id,
              onDelete: onDelete,
            );
          },
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final String courseId;
  final Function(String) onDelete;

  const _CourseCard({
    required this.course,
    required this.courseId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.7),
                Theme.of(context).primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.school, color: Colors.white),
        ),
        title: Text(
          course.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  course.code,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('• ${course.year}'),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              onPressed: () => _showEditDialog(context),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Description', course.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDetailChip(
                      'Credit Hours: ${course.creditHours}',
                      Icons.access_time,
                    ),
                    const SizedBox(width: 12),
                    _buildDetailChip(
                      course.semester,
                      Icons.calendar_today,
                    ),
                  ],
                ),
                if (course.prerequisites.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Prerequisites',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (course.prerequisites as List).map((prereq) {
                      return Chip(
                        label: Text(prereq),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        side: BorderSide(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: course.code);
    final nameController = TextEditingController(text: course.name);
    final descController = TextEditingController(text: course.description);
    String selectedYear = course.year;
    String selectedSemester = course.semester;
    int creditHours = course.creditHours;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Course Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedYear,
                  decoration: const InputDecoration(labelText: 'Year'),
                  items: academicYears
                      .map((year) =>
                          DropdownMenuItem(value: year, child: Text(year)))
                      .toList(),
                  onChanged: (v) => selectedYear = v!,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedSemester,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: semesters
                      .map((sem) =>
                          DropdownMenuItem(value: sem, child: Text(sem)))
                      .toList(),
                  onChanged: (v) => selectedSemester = v!,
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(courseId)
                      .update({
                    'code': codeController.text,
                    'name': nameController.text,
                    'description': descController.text,
                    'year': selectedYear,
                    'semester': selectedSemester,
                    'creditHours': creditHours,
                  });
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!dialogContext.mounted) return;
              await onDelete(courseId);
              // ignore: use_build_context_synchronously
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context as BuildContext).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              Theme.of(context as BuildContext).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context as BuildContext).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context as BuildContext).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:aaup/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCoursesPage extends StatefulWidget {
  const UserCoursesPage({super.key});

  @override
  State<UserCoursesPage> createState() => _UserCoursesPageState();
}

class _UserCoursesPageState extends State<UserCoursesPage> {
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  String? _selectedDepartment;
  String? _selectedYear;
  String? _selectedSemester;
  bool _isLoading = true;
  String? _registrationLink;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _fetchRegistrationLink();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await UserService.getCourses();
      setState(() {
        _courses = courses;
        _filteredCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load courses');
    }
  }

  Future<void> _fetchRegistrationLink() async {
    final link = await UserService.getRegistrationLink();
    setState(() {
      _registrationLink = link;
    });
  }

  void _filterCourses() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        final departmentMatch = _selectedDepartment == null ||
            course.department == _selectedDepartment;
        final yearMatch = _selectedYear == null || course.year == _selectedYear;
        final semesterMatch =
            _selectedSemester == null || course.semester == _selectedSemester;

        return departmentMatch && yearMatch && semesterMatch;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showCourseDetailsDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${course.code} - ${course.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Department', course.department),
              _buildDetailRow('Description', course.description),
              _buildDetailRow('Credit Hours', course.creditHours.toString()),
              _buildDetailRow('Year', course.year),
              _buildDetailRow('Semester', course.semester),
              if (course.prerequisites.isNotEmpty)
                _buildPrerequisitesSection(course.prerequisites),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPrerequisitesSection(List<String> prerequisites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Prerequisites:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...prerequisites.map((prereq) => Text('• $prereq')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Catalog'),
        actions: [
          if (_registrationLink != null)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => _launchRegistrationLink(),
              tooltip: 'Open Registration',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
            tooltip: 'Refresh Courses',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    value: _selectedDepartment,
                    hint: 'Department',
                    onChanged: (value) {
                      setState(() => _selectedDepartment = value);
                      _filterCourses();
                    },
                    items: engineeringDepartments,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomDropdown(
                    value: _selectedYear,
                    hint: 'Year',
                    onChanged: (value) {
                      setState(() => _selectedYear = value);
                      _filterCourses();
                    },
                    items: academicYears,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomDropdown(
                    value: _selectedSemester,
                    hint: 'Semester',
                    onChanged: (value) {
                      setState(() => _selectedSemester = value);
                      _filterCourses();
                    },
                    items: semesters,
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : _filteredCourses.isEmpty
                  ? const Expanded(
                      child: Center(child: Text('No courses found')))
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text('${course.code} - ${course.name}'),
                              subtitle: Text(
                                '${course.department} • ${course.year} • ${course.semester}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () =>
                                    _showCourseDetailsDialog(course),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  void _launchRegistrationLink() async {
    if (_registrationLink == null) return;

    try {
      // ignore: deprecated_member_use
      await launch(_registrationLink!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch link: $e')),
      );
    }
  }
}

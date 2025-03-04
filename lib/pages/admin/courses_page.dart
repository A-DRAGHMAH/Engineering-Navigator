import 'package:flutter/material.dart';
import '../../models/course_model.dart';
// ignore: unused_import
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditHoursController = TextEditingController();
  final _prerequisitesController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedYear;
  String? _selectedSemester;
  // ignore: unused_field
  final String _defaultDepartment = 'Computer Engineering';

  @override
  void initState() {
    super.initState();
    AdminService.createCoursesIndexes();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Courses'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Course'),
              Tab(text: 'View Courses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddCourseForm(),
            _buildCoursesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCourseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              items: engineeringDepartments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDepartment = value);
              },
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Course Code*',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Academic Year*',
                border: OutlineInputBorder(),
              ),
              items: [
                ...academicYears.map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSemester,
              decoration: const InputDecoration(
                labelText: 'Semester*',
                border: OutlineInputBorder(),
              ),
              items: [
                ...semesters.map((sem) => DropdownMenuItem(
                      value: sem,
                      child: Text(sem),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                });
              },
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _creditHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Credit Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prerequisitesController,
              decoration: const InputDecoration(
                labelText: 'Prerequisites (comma separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., CS101, CS102',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addCourse,
              child: const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .orderBy('department')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: engineeringDepartments.length,
          itemBuilder: (context, index) {
            final department = engineeringDepartments[index];
            final departmentCourses = courses.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['department'] == department;
            }).toList();

            if (departmentCourses.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    department,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...departmentCourses.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title:
                          Text('${data['code'] ?? ''} - ${data['name'] ?? ''}'),
                      subtitle: Text(
                        '${data['year'] ?? ''} • ${data['semester'] ?? ''} • ${data['creditHours']?.toString() ?? ''} Credits',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCourse(doc.id),
                      ),
                    ),
                  );
                }),
                const Divider(height: 32),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prerequisites = _prerequisitesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final course = CourseModel(
        id: '',
        code: _codeController.text,
        name: _nameController.text,
        department: _selectedDepartment!,
        description: _descriptionController.text,
        creditHours: int.parse(_creditHoursController.text),
        prerequisites: prerequisites,
        year: _selectedYear!,
        semester: _selectedSemester!,
      );

      await AdminService.addCourse(course);
      _clearForm();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteCourse(String id) async {
    try {
      await AdminService.deleteCourse(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _clearForm() {
    _codeController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _creditHoursController.clear();
    _prerequisitesController.clear();
    setState(() {
      _selectedDepartment = null;
      _selectedYear = null;
      _selectedSemester = null;
    });
  }
}

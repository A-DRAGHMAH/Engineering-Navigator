import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';

class AdminStudyMaterialsPage extends StatefulWidget {
  const AdminStudyMaterialsPage({super.key});

  @override
  State<AdminStudyMaterialsPage> createState() =>
      _AdminStudyMaterialsPageState();
}

class _AdminStudyMaterialsPageState extends State<AdminStudyMaterialsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedCourse;
  String? _selectedYear;
  String? _selectedSemester;
  bool _isUploading = false;

  final _departments = [
    'Computer Engineering',
    'Civil Engineering',
    'Architectural Engineering',
    'Mechanical Engineering',
    'Mechatronics Engineering',
    'Chemical Engineering',
    'Industrial Engineering',
    'Communications Engineering',
  ];

  final _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
  ];

  final _coursesByDepartment = {
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
    'Architectural Engineering': [
      'Architectural Design',
      'Urban Planning',
      'Sustainable Architecture',
      'Interior Design',
      'Building Systems',
      'Construction Technology',
      'Environmental Control',
    ],
    'Mechanical Engineering': [
      'Thermodynamics',
      'Fluid Mechanics',
      'Heat Transfer',
      'Machine Design',
      'Manufacturing Processes',
      'Control Systems',
      'Dynamics',
      'Materials Science',
      'Mechanical Vibrations',
      'CAD/CAM',
    ],
    'Mechatronics Engineering': [
      'Robotics',
      'Control Systems',
      'Automation',
      'Industrial Electronics',
      'Microprocessors',
      'Sensors and Actuators',
      'PLC Programming',
      'Mechatronic Design',
    ],
    'Chemical Engineering': [
      'Process Engineering',
      'Materials Engineering',
      'Environmental Engineering',
      'Chemical Reaction Engineering',
      'Transport Phenomena',
      'Plant Design',
    ],
    'Industrial Engineering': [
      'Operations Research',
      'Quality Engineering',
      'Manufacturing Systems',
      'Engineering Management',
      'Supply Chain Management',
      'Production Planning',
      'Ergonomics',
    ],
    'Communications Engineering': [
      'Telecommunications',
      'Signal Processing',
      'Wireless Communications',
      'Digital Communications',
      'Antenna Design',
      'Mobile Communications',
      'Optical Communications',
    ],
  };

  final _semesters = [
    'First Semester',
    'Second Semester',
    'Summer Semester',
  ];

  Future<void> _addMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      await AdminService.addStudyMaterial(
        title: _titleController.text,
        description: _descriptionController.text,
        url: _urlController.text,
        department: _selectedDepartment!,
        course: _selectedCourse,
        year: _selectedYear!,
        icon: Icons.book.codePoint,
        name: _titleController.text,
        semester: '1',
        fileType: 'url',
        tags: [],
        isPublic: true,
      );

      if (!mounted) return;
      _showSuccess('Material added successfully');
      _clearForm();
    } catch (e) {
      _showError('Error adding material: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _urlController.clear();
    setState(() {
      _selectedDepartment = null;
      _selectedCourse = null;
      _selectedYear = null;
      _selectedSemester = null;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Materials'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Material'),
              Tab(text: 'Manage Materials'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddMaterialForm(),
            _buildMaterialsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMaterialForm() {
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
              items: _departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedCourse = null;
                });
              },
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            if (_selectedDepartment != null)
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: const InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(),
                ),
                items: _coursesByDepartment[_selectedDepartment]?.map((course) {
                  return DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCourse = value),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedYear = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSemester,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                    items: _semesters.map((semester) {
                      return DropdownMenuItem(
                        value: semester,
                        child: Text(semester),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSemester = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter a title';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter a description';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter a URL';
                if (!Uri.tryParse(value!)!.hasAbsolutePath) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _addMaterial,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Add Material'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('study_materials')
          .orderBy('department')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final materials = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final doc = materials[index];
            final material = doc.data() as Map<String, dynamic>;

            return Dismissible(
              key: Key(doc.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                            'Are you sure you want to delete this material?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              },
              onDismissed: (direction) => _deleteMaterial(context, doc.id),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(material['title'] ?? ''),
                  subtitle: Text(
                    '${material['department']} - ${material['year']}\n${material['description']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red[400],
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                              'Are you sure you want to delete this material?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        if (!context.mounted) return;
                        _deleteMaterial(context, doc.id);
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMaterial(BuildContext context, String id) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('study_materials')
          .doc(id)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting material: $e')),
      );
    }
  }
}

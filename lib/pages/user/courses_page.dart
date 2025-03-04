// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserCoursesPage extends StatefulWidget {
  const UserCoursesPage({super.key});

  @override
  State<UserCoursesPage> createState() => _UserCoursesPageState();
}

class _UserCoursesPageState extends State<UserCoursesPage> {
  String _searchQuery = '';
  String? _selectedSpecialization;
  String? _selectedSemester;
  String? _selectedYear;
  final TextEditingController _searchController = TextEditingController();

  static const specializations = [
    'Computer Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
    'Architectural Engineering',
    'Communications Engineering',
    'Chemical Engineering',
    'Industrial Engineering',
  ];

  static const semesters = [
    'First Semester',
    'Second Semester',
    'Summer Semester',
  ];

  static const academicYears = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
    'Fifth Year',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Courses'),
      ),
      body: Column(
        children: [
          _buildSiteLink(),
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a237e), // Deep blue
                  const Color(0xFF0d47a1), // Rich blue
                  const Color(0xFF01579b), // Dark blue
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filters Row
                _buildFilters(),
              ],
            ),
          ),
          // Courses List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var courses = snapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {
                        ...data,
                        'id': doc.id,
                      };
                    }).toList() ??
                    [];

                // Apply filters
                courses = courses.where(_matchesFilters).toList();

                if (courses.isEmpty) {
                  return const Center(child: Text('No courses found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildCourseCard(course);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Row(
          children: [
            // Academic Year Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: InputDecoration(
                  hintText: 'Academic Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Years'),
                  ),
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
              ),
            ),
            const SizedBox(width: 12),
            // Semester Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  hintText: 'Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Semesters'),
                  ),
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Specialization Dropdown
        DropdownButtonFormField<String>(
          value: _selectedSpecialization,
          decoration: InputDecoration(
            hintText: 'Specialization',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Specializations'),
            ),
            ...specializations.map((spec) => DropdownMenuItem(
                  value: spec,
                  child: Text(spec),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSpecialization = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ExpansionTile(
          title: Text(
            course['name'] ?? '',
            style: const TextStyle(
              color: Color(0xFF1565C0), // Rich blue
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Code: ${course['code']}'),
              Text(
                '${course['academicYear']} - ${course['semester']}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.school,
              color: const Color(0xFF1565C0), // Rich blue
              size: 24,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course['description'] != null) ...[
                    const Text(
                      'Description:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(course['description']),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Specialization: ${course['specialization']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Credits: ${course['credits']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(course['url'] ?? ''),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Course Material'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0), // Rich blue
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.blue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilters(Map<String, dynamic> course) {
    final matchesSearch = course['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
        course['code']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

    final matchesSpecialization = _selectedSpecialization == null ||
        course['specialization'] == _selectedSpecialization;

    final matchesSemester =
        _selectedSemester == null || course['semester'] == _selectedSemester;

    final matchesYear =
        _selectedYear == null || course['academicYear'] == _selectedYear;

    return matchesSearch &&
        matchesSpecialization &&
        matchesSemester &&
        matchesYear;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildSiteLink() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () async {
            final Uri url =
                Uri.parse('https://sites.google.com/view/aaupeng/home');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    size: 24,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Engineering Navigator EDU Site',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () => _showQRDialog(context),
                ),
                const Icon(Icons.open_in_new),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Engineering Navigator EDU Site',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: 'https://sites.google.com/view/aaupeng/home',
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

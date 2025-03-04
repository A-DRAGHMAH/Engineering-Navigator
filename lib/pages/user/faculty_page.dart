// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/faculty_member_model.dart';

class UserFacultyPage extends StatefulWidget {
  const UserFacultyPage({super.key});

  @override
  State<UserFacultyPage> createState() => _UserFacultyPageState();
}

class _UserFacultyPageState extends State<UserFacultyPage> {
  String _searchQuery = '';
  String? _selectedDepartment;
  final TextEditingController _searchController = TextEditingController();

  // Engineering departments at AAUP
  static const departments = FacultyMemberModel.departments;

  Stream<List<FacultyMemberModel>> _getFacultyStream() {
    Query query = FirebaseFirestore.instance.collection('faculty');
    
    // Apply department filter if selected
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      query = query.where('department', isEqualTo: _selectedDepartment);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FacultyMemberModel(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          title: data['title']?.toString() ?? '',
          role: data['role']?.toString() ?? FacultyMemberModel.roles.first,
          department: data['department']?.toString() ?? '',
          officeLocation: data['officeLocation']?.toString() ?? '',
          phoneNumber: data['phoneNumber']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          bio: data['bio']?.toString() ?? '',
          imageUrl: data['imageUrl']?.toString(),
          officeHours: data['officeHours']?.toString() ?? '',
        );
      }).where((faculty) {
        final searchLower = _searchQuery.toLowerCase();
        final nameLower = faculty.name.toLowerCase();
        final departmentLower = faculty.department.toLowerCase();
        
        return searchLower.isEmpty || 
               nameLower.contains(searchLower) || 
               departmentLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Members'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search faculty members',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDepartment,
                  hint: const Text('Select Department'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Departments'),
                    ),
                    ...departments.map((department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FacultyMemberModel>>(
              stream: _getFacultyStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final facultyMembers = snapshot.data ?? [];
                
                if (facultyMembers.isEmpty) {
                  return const Center(child: Text('No faculty members found'));
                }

                return ListView.builder(
                  itemCount: facultyMembers.length,
                  itemBuilder: (context, index) {
                    final faculty = facultyMembers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: faculty.imageUrl != null
                              ? NetworkImage(faculty.imageUrl!)
                              : null,
                          child: faculty.imageUrl == null
                              ? Text(faculty.name[0].toUpperCase())
                              : null,
                        ),
                        title: Text(faculty.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(faculty.department),
                            Text(faculty.email),
                          ],
                        ),
                        onTap: () {
                          // Show faculty details
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(faculty.name),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Title: ${faculty.title}'),
                                    Text('Role: ${faculty.role}'),
                                    Text('Department: ${faculty.department}'),
                                    Text('Office: ${faculty.officeLocation}'),
                                    Text('Phone: ${faculty.phoneNumber}'),
                                    Text('Email: ${faculty.email}'),
                                    Text('Office Hours: ${faculty.officeHours}'),
                                    const SizedBox(height: 8),
                                    Text('Bio: ${faculty.bio}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChamferClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double chamferSize = 20.0;
    final path = Path();

    // Start from top-left after the chamfer
    path.moveTo(chamferSize, 0);

    // Top-right chamfer
    path.lineTo(size.width - chamferSize, 0);
    path.lineTo(size.width, chamferSize);

    // Bottom-right chamfer
    path.lineTo(size.width, size.height - chamferSize);
    path.lineTo(size.width - chamferSize, size.height);

    // Bottom-left chamfer
    path.lineTo(chamferSize, size.height);
    path.lineTo(0, size.height - chamferSize);

    // Back to start
    path.lineTo(0, chamferSize);
    path.lineTo(chamferSize, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_service.dart';
import '../../models/faculty_member_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AdminFacultyPage extends StatefulWidget {
  const AdminFacultyPage({super.key});

  @override
  State<AdminFacultyPage> createState() => _AdminFacultyPageState();
}

class _AdminFacultyPageState extends State<AdminFacultyPage> {
  final _nameController = TextEditingController();
  final _officeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedDepartment = FacultyMemberModel.departments.first;
  String? _selectedImagePath;
  Stream<List<FacultyMemberModel>>? _facultyStream;
  final _titleController = TextEditingController();
  final _officeHoursController = TextEditingController();
  String _selectedRole = FacultyMemberModel.roles.first;
  bool _isLoading = false;
  XFile? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _initFacultyStream();
  }

  void _initFacultyStream() {
    _facultyStream = AdminService.getFacultyStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        try {
          return FacultyMemberModel(
            id: doc.id,
            name: data['name']?.toString() ?? '',
            imageUrl: data['imageUrl']?.toString(),
            officeLocation: data['officeLocation']?.toString() ?? '',
            phoneNumber: data['phoneNumber']?.toString() ?? '',
            email: data['email']?.toString() ?? '',
            department: data['department']?.toString() ?? FacultyMemberModel.departments.first,
            bio: data['bio']?.toString() ?? '',
            title: data['title']?.toString() ?? '',
            role: data['role']?.toString() ?? FacultyMemberModel.roles.first,
            officeHours: data['officeHours']?.toString() ?? '',
          );
        } catch (e) {
          debugPrint('Error mapping faculty member data: $e');
          debugPrint('Problematic document ID: ${doc.id}');
          debugPrint('Data: $data');
          return FacultyMemberModel(
            id: doc.id,
            name: 'Unknown Faculty Member',
            imageUrl: null,
            officeLocation: '',
            phoneNumber: '',
            email: '',
            department: FacultyMemberModel.departments.first,
            bio: '',
            title: '',
            role: FacultyMemberModel.roles.first,
            officeHours: '',
          );
        }
      }).toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _officeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _titleController.dispose();
    _officeHoursController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        if (kIsWeb) {
          // For web, store the XFile directly
          setState(() {
            _selectedImageFile = image;
            _selectedImagePath = null;
          });
        } else {
          // For mobile, store the file path
          setState(() {
            _selectedImageFile = null;
            _selectedImagePath = image.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addFacultyMember() async {
    if (_nameController.text.isEmpty ||
        _officeController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AdminService.addFacultyMember(
        name: _nameController.text,
        department: _selectedDepartment,
        officeLocation: _officeController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        bio: _bioController.text,
        title: _titleController.text,
        role: _selectedRole,
        officeHours: _officeHoursController.text,
        imageFile: _selectedImagePath != null ? File(_selectedImagePath!) : null,
        webImageFile: _selectedImageFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faculty member added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _nameController.clear();
      _officeController.clear();
      _phoneController.clear();
      _emailController.clear();
      _bioController.clear();
      _titleController.clear();
      _officeHoursController.clear();
      setState(() {
        _selectedImagePath = null;
        _selectedDepartment = FacultyMemberModel.departments.first;
        _selectedRole = FacultyMemberModel.roles.first;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding faculty member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteFacultyMember(String id) async {
    if (!mounted) return;

    final BuildContext currentContext = context; // Store context

    try {
      await AdminService.deleteFacultyMember(id);

      if (!mounted) return;

      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Faculty member deleted successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Error deleting faculty member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFacultyImage(String name, String? imageUrl) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.blue.shade100,
      backgroundImage: imageUrl != null 
          ? NetworkImage(imageUrl) 
          : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random'),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Error loading image: $exception');
        // Fallback for when image fails to load
        setState(() {}); // Force rebuild with default child
      },
      child: imageUrl == null ? const Icon(
        Icons.person,
        size: 30,
        color: Colors.white,
      ) : null,
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (kIsWeb && _selectedImageFile != null) {
      return NetworkImage(_selectedImageFile!.path);
    } else if (!kIsWeb && _selectedImagePath != null) {
      return FileImage(File(_selectedImagePath!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Faculty'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Faculty Member',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: _getBackgroundImage(),
                                child: (_selectedImageFile == null && _selectedImagePath == null)
                                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: Colors.white),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name*',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: const InputDecoration(
                            labelText: 'Department*',
                            border: OutlineInputBorder(),
                          ),
                          items: FacultyMemberModel.departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _officeController,
                          decoration: const InputDecoration(
                            labelText: 'Office Location*',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number*',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address*',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Bio (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role*',
                            border: OutlineInputBorder(),
                          ),
                          items: FacultyMemberModel.roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title (Prof., Dr., etc.)*',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _officeHoursController,
                          decoration: const InputDecoration(
                            labelText: 'Office Hours*',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Mon, Wed 10:00-12:00',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _addFacultyMember,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Faculty Member'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              await AdminService.addInitialFacultyMembers();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Initial faculty members added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error adding faculty members: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          child: const Text('Add Initial Faculty Members'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Current Faculty Members',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<FacultyMemberModel>>(
                  stream: _facultyStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No faculty members found');
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final member = snapshot.data![index];
                          return Card(
                            child: ListTile(
                              leading: _buildFacultyImage(member.name, member.imageUrl),
                              title: Text(member.name),
                              subtitle: Text(member.department),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFacultyMember(member.id),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

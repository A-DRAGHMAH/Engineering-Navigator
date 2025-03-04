// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import '../../models/educational_program.dart';
import '../../services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/admin_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class UserEducationalProgramsPage extends StatefulWidget {
  const UserEducationalProgramsPage({super.key});

  @override
  State<UserEducationalProgramsPage> createState() =>
      _UserEducationalProgramsPageState();
}

class _UserEducationalProgramsPageState
    extends State<UserEducationalProgramsPage> {
  List<EducationalProgram> _allPrograms = [];
  List<EducationalProgram> _filteredPrograms = [];
  bool _isLoading = true;

  // Filtering variables
  String? _selectedSpecialty;
  String? _selectedLevel;

  // Specialty and level lists
  final List<String> _specialties = [
    'Architecture',
    'Biomedical Engineering',
    'Civil Engineering',
    'Computer Systems Engineering',
    'Cybersecurity Engineering',
    'Electrical Engineering',
    'Mechatronics Engineering',
    'Communications Engineering',
  ];

  final List<String> _levels = [
    'Undergraduate',
    'Graduate',
    'Postgraduate',
    'Professional Certificate'
  ];

  @override
  void initState() {
    super.initState();
    _loadEducationalPrograms();
  }

  Future<void> _loadEducationalPrograms() async {
    setState(() => _isLoading = true);
    try {
      final programs = await UserService.getEducationalPrograms();
      setState(() {
        _allPrograms = programs;
        _filteredPrograms = programs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load educational programs');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPrograms = _allPrograms.where((program) {
        bool matchesSpecialty = _selectedSpecialty == null ||
            program.specialty == _selectedSpecialty;

        bool matchesLevel =
            _selectedLevel == null || program.level == _selectedLevel;

        // You can add rating filter logic here when you implement ratings
        // bool matchesRating = _selectedRating == null ||
        //     program.rating >= _selectedRating;

        return matchesSpecialty && matchesLevel;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Educational Programs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Specialty Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSpecialty,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Specialties'),
                  ),
                  ..._specialties.map((specialty) => DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      ))
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value;
                  });
                  this.setState(() {
                    _selectedSpecialty = value;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Level Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Program Level',
                  border: OutlineInputBorder(),
                ),
                value: _selectedLevel,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Levels'),
                  ),
                  ..._levels.map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value;
                  });
                  this.setState(() {
                    _selectedLevel = value;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Rating Slider (Placeholder for future rating implementation)
              // const Text('Program Rating'),
              // Slider(
              //   value: _selectedRating ?? 0,
              //   min: 0,
              //   max: 5,
              //   divisions: 5,
              //   label: _selectedRating?.toString() ?? 'Any',
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedRating = value;
              //     });
              //     this.setState(() {
              //       _selectedRating = value;
              //       _applyFilters();
              //     });
              //   },
              // ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showRatingDialog(EducationalProgram program) {
    final commentController = TextEditingController();
    double selectedRating = 3.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate ${program.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: selectedRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                selectedRating = rating;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Optional Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // توليد معرف مؤقت للمستخدم المجهول
                String userId =
                    'anonymous_${DateTime.now().millisecondsSinceEpoch}';

                // التحقق من صحة التقييم
                if (selectedRating < 1 || selectedRating > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a valid rating'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await AdminService.addProgramRating(
                  programId: program.id,
                  userId: userId,
                  ratingValue: selectedRating,
                  comment: commentController.text.trim(),
                );

                // إعادة تحميل البرامج
                await _loadEducationalPrograms();

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your rating!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('❌ Rating Submission Error: $e');

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit Rating'),
          ),
        ],
      ),
    );
  }

  // Helper method to generate a unique anonymous user ID
  // ignore: unused_element
  String _generateAnonymousUserId() {
    // You can use a combination of timestamp and random string
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = _generateRandomString(8);
    return 'anonymous_$timestamp$randomString';
  }

  // Generate a random string of specified length
  String _generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
        length, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  // دالة لاختيار الأيقونة حسب التخصص
  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'Architecture':
        return Icons.architecture;
      case 'Biomedical Engineering':
        return Icons.medical_services;
      case 'Civil Engineering':
        return Icons.engineering;
      case 'Computer Systems Engineering':
        return Icons.computer;
      case 'Cybersecurity Engineering':
        return Icons.security;
      case 'Electrical Engineering':
        return Icons.electrical_services;
      case 'Mechatronics Engineering':
        return Icons.precision_manufacturing;
      case 'Communications Engineering':
        return Icons.signal_cellular_alt;
      default:
        return Icons.school;
    }
  }

  Widget _buildProgramCard(EducationalProgram program) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // أيقونة التخصص في أعلى البطاقة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.shade200.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        _getSpecialtyIcon(program.specialty),
                        color: Colors.blue.shade800,
                        size: 30,
                      ),
                      Text(
                        program.specialty,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.school,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${program.level} • ${program.language}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${program.duration}',
                            style: TextStyle(color: Colors.blue.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Instructor: ${program.instructorName.isNotEmpty ? program.instructorName : 'Not specified'}',
                              style: TextStyle(color: Colors.blue.shade800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Rating: ${program.averageRating.toStringAsFixed(1)}/5',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.rate_review),
                            onPressed: () => _showRatingDialog(program),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (program.registrationLink != null &&
                          program.registrationLink!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _launchRegistrationLink(
                              program.registrationLink!),
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Register Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // زر المعلومات الإضافية
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.blue.shade800),
              onPressed: () => _showProgramDetailsDialog(program),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgramDetailsDialog(EducationalProgram program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(program.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Description', program.description),
              _buildDetailRow('Specialty', program.specialty),
              _buildDetailRow('Level', program.level),
              _buildDetailRow('Language', program.language),
              _buildDetailRow('Duration', program.duration),
              _buildDetailRow('Instructor', program.instructorName),
              _buildDetailRow('Contact Info', program.contactInfo),
              _buildDetailRow('Start Date',
                  DateFormat('dd MMM yyyy HH:mm').format(program.startDate)),
              _buildDetailRow('End Date',
                  DateFormat('dd MMM yyyy HH:mm').format(program.endDate)),
              if (program.price > 0)
                _buildDetailRow(
                    'Price', '\$${program.price.toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          if (program.registrationLink != null &&
              program.registrationLink!.isNotEmpty)
            TextButton.icon(
              onPressed: () =>
                  _launchRegistrationLink(program.registrationLink!),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Register'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to build consistent detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter Programs',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPrograms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No programs found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Reset filters
                          setState(() {
                            _selectedSpecialty = null;
                            _selectedLevel = null;
                            _filteredPrograms = _allPrograms;
                          });
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _filteredPrograms.length,
                  itemBuilder: (context, index) {
                    return _buildProgramCard(_filteredPrograms[index]);
                  },
                ),
    );
  }

  Future<void> _launchRegistrationLink(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

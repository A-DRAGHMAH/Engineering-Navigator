// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/educational_program.dart';
import '../../services/admin_service.dart';

class AdminEducationalProgramsPage extends StatefulWidget {
  const AdminEducationalProgramsPage({super.key});

  @override
  State<AdminEducationalProgramsPage> createState() =>
      _AdminEducationalProgramsPageState();
}

class _AdminEducationalProgramsPageState
    extends State<AdminEducationalProgramsPage> {
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructorNameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _registrationLinkController = TextEditingController();

  // State variables
  List<EducationalProgram> _programs = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  // Dropdown selections
  String? _selectedSpecialty;
  String? _selectedLevel;
  String? _selectedLanguage;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Lists for dropdowns
  final List<String> _levels = [
    'Undergraduate',
    'Graduate',
    'Postgraduate',
    'Professional Certificate'
  ];

  final List<String> _languages = ['English', 'Arabic', 'Bilingual'];

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

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() => _isLoading = true);
    try {
      final programs = await AdminService.getEducationalProgramsWithRatings();
      setState(() {
        _programs = programs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load programs');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showAddProgramDialog() {
    // Reset controllers and selections before showing the dialog
    _titleController.clear();
    _descriptionController.clear();
    _durationController.clear();
    _registrationLinkController.clear();
    _selectedSpecialty = null;
    _selectedLevel = null;
    _selectedLanguage = null;
    _startDate = null;
    _endDate = null;
    _startTime = null;
    _endTime = null;

    showDialog(
      context: context,
      builder: (context) => _buildAddProgramDialog(),
    );
  }

  Widget _buildAddProgramDialog() {
    return AlertDialog(
      title: const Text('Add Educational Program'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title - Remove validator
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Program Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description - Remove validator
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Program Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Specialty Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: const InputDecoration(
                labelText: 'Specialty',
                border: OutlineInputBorder(),
              ),
              items: _specialties
                  .map((specialty) => DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSpecialty = value),
            ),
            const SizedBox(height: 16),

            // Level Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Program Level',
                border: OutlineInputBorder(),
              ),
              items: _levels
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedLevel = value),
            ),
            const SizedBox(height: 16),

            // Language Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Program Language',
                border: OutlineInputBorder(),
              ),
              items: _languages
                  .map((language) => DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value),
            ),
            const SizedBox(height: 16),

            // Duration
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Program Duration (e.g., 4 Years)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Registration Link
            TextField(
              controller: _registrationLinkController,
              decoration: const InputDecoration(
                labelText: 'Registration Link',
                hintText: 'Optional: Enter program registration URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Start Date and Time
            ListTile(
              title: Text(_formatDateTime()),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectStartDateTime(context),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitNewProgram,
          child: const Text('Add Program'),
        ),
      ],
    );
  }

  void _submitNewProgram() {
    // Comprehensive validation when Add Program is pressed
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program title is required')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program description is required')),
      );
      return;
    }

    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialty')),
      );
      return;
    }

    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a program level')),
      );
      return;
    }

    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a program language')),
      );
      return;
    }

    if (_durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program duration is required')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    try {
      // دمج التاريخ والوقت للبداية والنهاية
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime?.hour ?? 0,
        _startTime?.minute ?? 0,
      );

      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime?.hour ?? 23,
        _endTime?.minute ?? 59,
      );

      final program = EducationalProgram(
        id: '', // Firestore will generate an ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        specialty: _selectedSpecialty!,
        duration: _durationController.text.trim(),
        level: _selectedLevel!,
        language: _selectedLanguage!,
        instructorName: '', // Optional, can be added later
        contactInfo: '', // Optional, can be added later
        startDate: startDateTime,
        endDate: endDateTime,
        modules: [],
        lessons: [],
        resources: [],
        assignments: [],
        instructorQualifications: '',
        enrollmentLimit: 0,
        price: 0.0,
        status: 'Active',
        registrationLink: _registrationLinkController.text.trim(),
        startTime: _startTime,
      );

      // Call method to add the program
      _addProgram(program);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating program: $e')),
      );
    }
  }

  Future<void> _addProgram(EducationalProgram program) async {
    try {
      await AdminService.addEducationalProgram(program);
      await _loadPrograms();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Failed to add program');
    }
  }

  Future<void> _selectStartDateTime(BuildContext context) async {
    final initialDate = DateTime.now();

    // اختيار تاريخ البداية
    final pickedStartDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(initialDate.year + 5),
    );

    if (pickedStartDate != null) {
      // اختيار وقت البداية
      final pickedStartTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now(),
      );

      // اختيار تاريخ النهاية
      final pickedEndDate = await showDatePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialDate: pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime(pickedStartDate.year + 5),
      );

      if (pickedEndDate != null) {
        // اختيار وقت النهاية
        final pickedEndTime = await showTimePicker(
          // ignore: use_build_context_synchronously
          context: context,
          initialTime: TimeOfDay.now(),
        );

        setState(() {
          _startDate = pickedStartDate;
          _startTime = pickedStartTime;
          _endDate = pickedEndDate;
          _endTime = pickedEndTime;
        });
      }
    }
  }

  String _formatDateTime() {
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      return 'Select Start and End Date/Time';
    }

    final combinedStartDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final combinedEndDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    return 'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(combinedStartDateTime)}\n'
        'End: ${DateFormat('yyyy-MM-dd HH:mm').format(combinedEndDateTime)}';
  }

  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _specialtyController.dispose();
    _durationController.dispose();
    _instructorNameController.dispose();
    _contactInfoController.dispose();
    _registrationLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Programs Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrograms,
            tooltip: 'Refresh Programs',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Program'),
              onPressed: _showAddProgramDialog,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _programs.isEmpty
              ? const Center(child: Text('No educational programs found'))
              : Form(
                  key: _formKey,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _programs.length,
                    itemBuilder: (context, index) {
                      final program = _programs[index];
                      return _buildProgramListTile(program);
                    },
                  ),
                ),
    );
  }

  Widget _buildProgramListTile(EducationalProgram program) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ExpansionTile(
        leading: Icon(
          _getSpecialtyIcon(program.specialty),
          color: Colors.blue.shade700,
        ),
        title: Text(
          program.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              program.specialty,
              style: TextStyle(color: Colors.blue.shade700),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                Text(
                  '${program.averageRating.toStringAsFixed(1)}/5',
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _showProgramDetails(program),
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProgram(program),
              tooltip: 'Delete Program',
            ),
          ],
        ),
        children: [
          // Ratings Section
          if (program.ratings.isNotEmpty)
            Container(
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'User Ratings (${program.ratings.length} total)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  ...program.ratings.map((rating) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            rating.value.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'User ID: ${rating.userId}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        subtitle: Text(
                          rating.comment.isNotEmpty
                              ? rating.comment
                              : 'No comment provided',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Text(
                          DateFormat('dd MMM yyyy').format(rating.timestamp),
                          style: const TextStyle(fontSize: 10),
                        ),
                      )),
                ],
              ),
            ),
          if (program.ratings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No ratings yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to get specialty icon
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

  void _showProgramDetails(EducationalProgram program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(program.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show fields that are likely to have been entered
              if (program.specialty.isNotEmpty)
                _buildDetailRow('Specialty', program.specialty),
              if (program.duration.isNotEmpty)
                _buildDetailRow('Duration', program.duration),
              if (program.level.isNotEmpty)
                _buildDetailRow('Level', program.level),
              if (program.language.isNotEmpty)
                _buildDetailRow('Language', program.language),
              if (program.instructorName.isNotEmpty)
                _buildDetailRow('Instructor', program.instructorName),

              // Date formatting
              _buildDetailRow('Start Date',
                  DateFormat('dd MMM yyyy HH:mm').format(program.startDate)),
              _buildDetailRow('End Date',
                  DateFormat('dd MMM yyyy HH:mm').format(program.endDate)),

              // Only show price if it's not zero
              if (program.price > 0)
                _buildDetailRow(
                    'Price', '\$${program.price.toStringAsFixed(2)}'),

              // Registration link
              if (program.registrationLink != null &&
                  program.registrationLink!.isNotEmpty)
                _buildDetailRow('Registration', program.registrationLink!),

              // عرض التقييمات
              const Text(
                'Ratings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Average Rating: ${program.averageRating.toStringAsFixed(1)}/5',
                style: TextStyle(color: Colors.amber.shade700),
              ),
              ...program.ratings.map((rating) => ListTile(
                    title: Text('User: ${rating.userId}'),
                    subtitle: Text(rating.comment),
                    trailing: Text(
                      '${rating.value}/5',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
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

  Future<void> _deleteProgram(EducationalProgram program) async {
    try {
      // Advanced admin permission check
      final isAdmin = await AdminService.isAdminLoggedIn();
      if (!isAdmin) {
        _showErrorSnackBar('You do not have permission to delete programs');
        return;
      }

      // Show confirmation dialog
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the program "${program.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        // Delete the program
        await AdminService.deleteEducationalProgram(program.id);

        // Reload the list
        await _loadPrograms();

        // Show success message
        _showSuccessSnackBar('Program deleted successfully');
      }
    } catch (e) {
      // Detailed error handling
      _showErrorSnackBar('Failed to delete program: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/course_model.dart';

class AddCourseDialog extends StatefulWidget {
  final Function(CourseModel) onAdd;

  const AddCourseDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  // Add form controllers and state variables
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Course'),
      content: Form(
        key: _formKey,
        child: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form fields
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
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submitForm() {
    // Implement form submission
  }
} 
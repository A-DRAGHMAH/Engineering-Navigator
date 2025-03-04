import 'package:flutter/material.dart';
import '../../models/exam_schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminExamSchedulesPage extends StatefulWidget {
  const AdminExamSchedulesPage({super.key});

  @override
  State<AdminExamSchedulesPage> createState() => _AdminExamSchedulesPageState();
}

class _AdminExamSchedulesPageState extends State<AdminExamSchedulesPage> {
  final _linkController = TextEditingController();
  String _selectedType = ExamScheduleModel.examTypes.first;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _uploadSchedule() async {
    if (_linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid link')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('examSchedules').add({
        'type': _selectedType,
        'url': _linkController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _linkController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading schedule: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exam Schedules'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Exam Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ExamScheduleModel.examTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Schedule Link',
                        border: OutlineInputBorder(),
                        hintText: 'Paste the schedule URL here...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _uploadSchedule,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Schedule'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Current Schedules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('examSchedules').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final schedules = snapshot.data?.docs ?? [];
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(schedule['type']),
                        subtitle: Text('Updated: ${(schedule['updatedAt'] as Timestamp).toDate().toString().split('.')[0]}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('examSchedules')
                                  .doc(schedules[index].id)
                                  .delete();
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Schedule deleted successfully')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting schedule: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 
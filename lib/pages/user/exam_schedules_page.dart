import 'package:flutter/material.dart';
import '../../models/exam_schedule_model.dart';
import '../../services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserExamSchedulesPage extends StatelessWidget {
  const UserExamSchedulesPage({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedules'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getDataStream('examSchedules'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final schedules = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ExamScheduleModel.fromJson(doc.id, data);
          }).toList() ?? [];

          if (schedules.isEmpty) {
            return const Center(
              child: Text('No exam schedules available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(schedule.type),
                  subtitle: Text(
                    'Updated: ${schedule.updatedAt.toLocal().toString().split('.')[0]}',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _launchUrl(schedule.url);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
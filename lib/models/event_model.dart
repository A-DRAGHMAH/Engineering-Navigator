import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String description;
  final bool isPublic;
  final String? createdBy;
  final DateTime? createdAt;

  EventModel({
    this.id = '',
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.description,
    this.isPublic = true,
    this.createdBy,
    this.createdAt,
  });

  static List<String> get eventTypes => [
    'Lecture',
    'Workshop',
    'Exam',
    'Meeting',
    'Holiday',
    'Other',
  ];

  Color getEventColor() {
    switch (type.toLowerCase()) {
      case 'lecture':
        return Colors.blue;
      case 'workshop':
        return Colors.orange;
      case 'exam':
        return Colors.red;
      case 'meeting':
        return Colors.purple;
      case 'holiday':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getEventIcon() {
    switch (type.toLowerCase()) {
      case 'exam':
        return Icons.assignment;
      case 'lecture':
        return Icons.school;
      case 'workshop':
        return Icons.build;
      case 'meeting':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  static EventModel fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? 'Other',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      isPublic: data['isPublic'] ?? true,
      createdBy: data['createdBy'],
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'description': description,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
} 
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
import 'package:flutter/src/material/time.dart';
// ignore: implementation_imports

class EducationalProgram {
  final String id;
  final String title;
  final String description;
  final String specialty;
  final String duration;
  final String level;
  final String language;
  final List<String> modules;
  final List<String> lessons;
  final List<String> resources;
  final List<String> assignments;
  final String instructorName;
  final String instructorQualifications;
  final String contactInfo;
  final DateTime startDate;
  final DateTime endDate;
  final int enrollmentLimit;
  final double price;
  final String status;
  final String? registrationLink;
  final List<Rating> ratings;
  final double averageRating;

  EducationalProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.specialty,
    required this.duration,
    required this.level,
    required this.language,
    required this.modules,
    required this.lessons,
    required this.resources,
    required this.assignments,
    required this.instructorName,
    required this.instructorQualifications,
    required this.contactInfo,
    required this.startDate,
    required this.endDate,
    required this.enrollmentLimit,
    required this.price,
    required this.status,
    this.registrationLink,
    this.ratings = const [],
    this.averageRating = 0.0,
    TimeOfDay? startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'specialty': specialty,
      'duration': duration,
      'level': level,
      'language': language,
      'modules': modules,
      'lessons': lessons,
      'resources': resources,
      'assignments': assignments,
      'instructorName': instructorName,
      'instructorQualifications': instructorQualifications,
      'contactInfo': contactInfo,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'enrollmentLimit': enrollmentLimit,
      'price': price,
      'status': status,
      'registrationLink': registrationLink,
      'ratings': ratings.map((r) => r.toMap()).toList(),
      'averageRating': averageRating,
    };
  }

  factory EducationalProgram.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EducationalProgram(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      specialty: data['specialty'],
      duration: data['duration'],
      level: data['level'],
      language: data['language'],
      modules: List<String>.from(data['modules']),
      lessons: List<String>.from(data['lessons']),
      resources: List<String>.from(data['resources']),
      assignments: List<String>.from(data['assignments']),
      instructorName: data['instructorName'],
      instructorQualifications: data['instructorQualifications'],
      contactInfo: data['contactInfo'],
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      enrollmentLimit: data['enrollmentLimit'],
      price: data['price'],
      status: data['status'],
      registrationLink: data['registrationLink'],
      ratings: data['ratings'] != null
          ? List<Rating>.from((data['ratings'] as List).map((ratingData) =>
              Rating.fromMap(ratingData as Map<String, dynamic>)))
          : [],
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // You can add methods for JSON serialization/deserialization if needed
}

class Rating {
  final String userId;
  final double value;
  final String comment;
  final DateTime timestamp;

  Rating({
    required this.userId,
    required this.value,
    this.comment = '',
    required this.timestamp,
  });

  factory Rating.fromMap(Map<String, dynamic> data) {
    return Rating(
      userId: data['userId'] ?? 'Unknown User',
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'] is String
          ? DateTime.parse(data['timestamp'])
          : data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'value': value,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

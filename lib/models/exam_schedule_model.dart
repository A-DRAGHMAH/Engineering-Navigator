import 'package:cloud_firestore/cloud_firestore.dart';

class ExamScheduleModel {
  final String id;
  final String type;
  final String url;
  final DateTime updatedAt;

  static const List<String> examTypes = [
    'First Exam',
    'Second Exam',
    'Final Exam',
    'Make-up Exam',
  ];

  ExamScheduleModel({
    required this.id,
    required this.type,
    required this.url,
    required this.updatedAt,
  });

  factory ExamScheduleModel.fromJson(String id, Map<String, dynamic> json) {
    return ExamScheduleModel(
      id: id,
      type: json['type'] as String,
      url: json['url'] as String,
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
} 
import 'package:flutter/material.dart';

class LinkModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final DateTime uploadedAt;

  LinkModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  static List<String> get linkTypes => [
    'Video',
    'Website',
    'Document',
  ];

  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'administrative':
        return Icons.business;
      case 'library':
        return Icons.library_books;
      case 'student services':
        return Icons.people;
      default:
        return Icons.link;
    }
  }

  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'administrative':
        return Colors.orange;
      case 'library':
        return Colors.green;
      case 'student services':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 
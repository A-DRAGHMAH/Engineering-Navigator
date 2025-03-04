import 'package:cloud_firestore/cloud_firestore.dart';

class HallVideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String hallNumber;
  final String floor;
  final String locationDescription;
  final String uploadedBy;
  final DateTime uploadedAt;
  final bool isPublic;

  HallVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.hallNumber,
    required this.floor,
    required this.locationDescription,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.isPublic,
  });

  factory HallVideoModel.fromMap(String id, Map<String, dynamic> map) {
    return HallVideoModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      hallNumber: map['hallNumber'] ?? '',
      floor: map['floor'] ?? '',
      locationDescription: map['locationDescription'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      isPublic: map['isPublic'] ?? false,
    );
  }
}

class HallLocation {
  final String hallName;
  final String coordinates;
  final String description;

  HallLocation({
    required this.hallName,
    required this.coordinates,
    required this.description,
  });

  factory HallLocation.fromMap(Map<String, dynamic> map) {
    return HallLocation(
      hallName: map['hallName'] ?? '',
      coordinates: map['coordinates'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

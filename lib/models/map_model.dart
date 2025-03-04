class MapModel {
  final String id;
  final String name;
  final String modelUrl;
  final List<MapLocation> locations;

  MapModel({
    required this.id,
    required this.name,
    required this.modelUrl,
    required this.locations,
  });

  factory MapModel.fromJson(String id, Map<String, dynamic> json) {
    return MapModel(
      id: id,
      name: json['name'] as String,
      modelUrl: json['modelUrl'] as String,
      locations: (json['locations'] as List<dynamic>)
          .map((e) => MapLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'modelUrl': modelUrl,
        'locations': locations.map((e) => e.toJson()).toList(),
      };
}

class MapLocation {
  final String name;
  final String type;
  final String floor;
  final double x;
  final double y;
  final double z;

  static const List<String> locationTypes = [
    'Classroom',
    'Office',
    'Lab',
    'Bathroom',
    'Stairs',
    'Elevator',
    'Other'
  ];

  MapLocation({
    required this.name,
    required this.type,
    required this.floor,
    required this.x,
    required this.y,
    required this.z,
  });

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    return MapLocation(
      name: json['name'] as String,
      type: json['type'] as String,
      floor: json['floor'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  factory MapLocation.empty() {
    return MapLocation(
      name: '',
      type: locationTypes.first,
      floor: 'Ground Floor',
      x: 0,
      y: 0,
      z: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'floor': floor,
        'x': x,
        'y': y,
        'z': z,
      };
} 
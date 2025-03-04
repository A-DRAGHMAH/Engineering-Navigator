import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../services/firebase_service.dart';
import '../../models/map_model.dart';

class UserMapsPage extends StatefulWidget {
  const UserMapsPage({super.key});

  @override
  State<UserMapsPage> createState() => _UserMapsPageState();
}

class _UserMapsPageState extends State<UserMapsPage> {
  final _searchController = TextEditingController();
  String? _selectedLocation;
  Stream<List<MapModel>>? _mapsStream;
  MapModel? _selectedMap;

  @override
  void initState() {
    super.initState();
    _initMapsStream();
  }

  void _initMapsStream() {
    _mapsStream = FirebaseService.getDataStream('maps').map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MapModel.fromJson(doc.id, data);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRouteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Route Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.stairs),
              title: const Text('Via Stairs'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  // Implement route visualization logic here
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.elevator),
              title: const Text('Via Elevator'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  // Implement route visualization logic here
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _searchLocation(String searchTerm, List<MapLocation> locations) {
    if (searchTerm.isEmpty) {
      setState(() {
        _selectedLocation = null;
      });
      return;
    }

    final matchingLocation = locations
        .where((loc) => loc.name.toLowerCase().contains(searchTerm.toLowerCase()))
        .firstOrNull;

    if (matchingLocation != null) {
      setState(() {
        _selectedLocation = matchingLocation.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Maps'),
      ),
      body: StreamBuilder<List<MapModel>>(
        stream: _mapsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final maps = snapshot.data!;
          if (_selectedMap == null && maps.isNotEmpty) {
            _selectedMap = maps.first;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Location',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Implement location search
                        final searchTerm = _searchController.text.toLowerCase();
                        final locations = _selectedMap?.locations ?? [];
                        _searchLocation(searchTerm, locations);
                      },
                    ),
                  ),
                ),
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _showRouteDialog,
                    icon: const Icon(Icons.directions),
                    label: const Text('Show Route'),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: _selectedMap != null
                      ? ModelViewer(
                          src: _selectedMap!.modelUrl,
                          alt: 'A 3D model of the building',
                          autoRotate: false,
                          cameraControls: true,
                        )
                      : const Center(child: Text('No maps available')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 
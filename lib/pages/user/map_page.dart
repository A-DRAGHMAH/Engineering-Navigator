import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMapPage extends StatelessWidget {
  const UserMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('maps')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final maps = snapshot.data?.docs ?? [];
          if (maps.isEmpty) {
            return const Center(child: Text('No maps available'));
          }

          // Get the latest map
          final latestMap = maps.first.data() as Map<String, dynamic>;
          final mapUrl = latestMap['url'] as String;
          final mapName = latestMap['name'] as String;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  mapName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ModelViewer(
                  src: mapUrl,
                  alt: mapName,
                  autoRotate: true,
                  cameraControls: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
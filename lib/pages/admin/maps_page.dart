// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/map_model.dart';
import '../../services/firebase_service.dart';
import 'dart:io';
import '../../services/admin_service.dart';

class AdminMapsPage extends StatefulWidget {
  const AdminMapsPage({super.key});

  @override
  State<AdminMapsPage> createState() => _AdminMapsPageState();
}

class _AdminMapsPageState extends State<AdminMapsPage> {
  bool _isUploading = false;
  String? _selectedFilePath;
  final _nameController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _zController = TextEditingController();
  
  // ignore: unused_field
  String? _selectedModelPath;
  // ignore: unused_field
  final List<String> _floors = ['Ground Floor', '1st Floor', '2nd Floor'];
  Stream<List<MapModel>>? _mapsStream;

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
    _nameController.dispose();
    _locationNameController.dispose();
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    if (_nameController.text.isEmpty) {
      _showError('Please enter a map name');
      return;
    }

    setState(() => _isUploading = true);  // Show loading state

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb', 'gltf'],
        withData: true,
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.single.bytes!;
          await AdminService.uploadMapWeb(
            name: _nameController.text,
            bytes: bytes,
            fileName: result.files.single.name,
          );
        } else {
          final file = File(result.files.single.path!);
          await AdminService.uploadMap(
            name: _nameController.text,
            file: file,
          );
        }

        if (!mounted) return;
        _showSuccess('Map uploaded successfully');
        _nameController.clear();
      }
    } catch (e) {
      _showError('Error uploading map: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Maps'),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Map Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickAndUploadFile,
                          icon: _isUploading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.upload_file),
                          label: Text(_isUploading ? 'Uploading...' : 'Upload Map'),
                        ),
                        if (_selectedFilePath != null) ...[
                          const SizedBox(height: 8),
                          Text('Selected: ${_selectedFilePath!.split('/').last}'),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _pickAndUploadFile,
                          child: _isUploading
                              ? const CircularProgressIndicator()
                              : const Text('Upload Map'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Uploaded Maps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: maps.length,
                  itemBuilder: (context, index) {
                    final map = maps[index];
                    return Card(
                      child: ListTile(
                        title: Text(map.name),
                        subtitle: Text('Locations: ${map.locations.length}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            if (!mounted) return;
                            try {
                              await FirebaseService.deleteData('maps', map.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Map deleted successfully')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting map: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
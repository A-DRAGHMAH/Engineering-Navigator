// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../widgets/video_player_screen.dart';
import '../../services/appwrite_service.dart';

class AdminHallVideosPage extends StatefulWidget {
  const AdminHallVideosPage({super.key});

  @override
  State<AdminHallVideosPage> createState() => _AdminHallVideosPageState();
}

class _AdminHallVideosPageState extends State<AdminHallVideosPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hallNumberController = TextEditingController();
  final _locationDescController = TextEditingController();
  String? _selectedFloor;
  dynamic _videoFile;
  bool _isUploading = false;

  // List of available floors
  final List<String> _floors = [
    'Ground Floor',
    'First Floor',
    'Second Floor',
    'Third Floor',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Hall Videos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upload Video'),
              Tab(text: 'View Videos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUploadForm(),
            _buildVideosList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadForm() {
    return FocusScope(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hallNumberController,
                decoration: const InputDecoration(
                  labelText: 'Hall Number*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFloor,
                decoration: const InputDecoration(
                  labelText: 'Floor*',
                  border: OutlineInputBorder(),
                ),
                items: _floors.map((floor) {
                  return DropdownMenuItem(value: floor, child: Text(floor));
                }).toList(),
                onChanged: (value) => setState(() => _selectedFloor = value),
                validator: (value) =>
                    value == null ? 'Please select a floor' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationDescController,
                decoration: const InputDecoration(
                  labelText: 'Location Description*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label:
                    Text(_videoFile == null ? 'Select Video' : 'Change Video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              if (_videoFile != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadVideo,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Video'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideosList() {
    return FutureBuilder<PaginatedResult>(
      future: AppwriteService.getHallVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final videos = snapshot.data?.items ?? [];
        if (videos.isEmpty) {
          return const Center(child: Text('No videos uploaded yet'));
        }

        // Filter videos by selected floor
        final filteredVideos = videos.where((video) {
          return _selectedFloor == null ||
              _selectedFloor == 'All Floors' ||
              video['floor'].toString() == _selectedFloor;
        }).toList();

        if (filteredVideos.isEmpty) {
          return Center(
            child: Text(_selectedFloor != null
                ? 'No videos found for $_selectedFloor'
                : 'No videos found'),
          );
        }

        return ListView.builder(
          itemCount: filteredVideos.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final video = filteredVideos[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(video['title'] ?? ''),
                subtitle: Text(
                  'Hall: ${video['hallNumber']} - ${video['floor']}\n${video['description'] ?? ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(video['fileId']),
                ),
                onTap: () => _playVideo(video['fileId']),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _videoFile = kIsWeb ? pickedFile : File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate() || _videoFile == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName =
          'hall_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final fileId = await AppwriteService.uploadVideo(
        _videoFile,
        fileName,
      );

      await AppwriteService.createHallVideo(
        title: _titleController.text,
        description: _descriptionController.text,
        fileId: fileId,
        hallNumber: _hallNumberController.text,
        floor: _selectedFloor!,
        locationDescription: _locationDescController.text,
      );

      _clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _confirmDelete(String fileId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteVideo(fileId);
    }
  }

  Future<void> _deleteVideo(String fileId) async {
    try {
      await AppwriteService.deleteVideo(fileId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting video: $e')),
      );
    }
  }

  Future<void> _playVideo(String fileId) async {
    try {
      final loadingContext = context;
      showDialog(
        context: loadingContext,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('Loading video...'),
            ],
          ),
        ),
      );

      final videoUrl = await AppwriteService.getVideoUrl(fileId);
      if (!mounted) return;

      Navigator.of(loadingContext).pop();

      // Modified to match AI response handler behavior
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            url: videoUrl,
            autoPlay: true,  // Add this parameter
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Ensure loading dialog is removed
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing video: ${e.toString()}'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _hallNumberController.clear();
    _locationDescController.clear();
    setState(() {
      _selectedFloor = null;
      _videoFile = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hallNumberController.dispose();
    _locationDescController.dispose();
    super.dispose();
  }
}

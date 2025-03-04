// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../widgets/video_player_screen.dart';
import '../../services/appwrite_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserHallVideosPage extends StatefulWidget {
  const UserHallVideosPage({super.key});

  @override
  State<UserHallVideosPage> createState() => _UserHallVideosPageState();
}

class _UserHallVideosPageState extends State<UserHallVideosPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFloor;
  bool _isLoading = true;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _videos = [];
  String? _lastId;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() => _isLoading = true);
      } else {
        setState(() => _isLoadingMore = true);
      }

      final videos = await AppwriteService.getHallVideos(
        limit: _pageSize,
        lastId: loadMore ? _lastId : null,
      );

      setState(() {
        if (!loadMore) {
          _videos = videos.items;
        } else {
          _videos.addAll(videos.items);
        }
        _lastId = videos.lastId;
        _hasMore = videos.items.length >= _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading videos: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall Videos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search videos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                _buildFloorFilter(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildVideosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList() {
    final filteredVideos = _videos.where((video) {
      final matchesSearch = video['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          video['description']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          video['hallNumber']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Improved floor filtering logic
      final matchesFloor = _selectedFloor == null || 
                          _selectedFloor == 'All Floors' ||
                          video['floor'].toString().trim() == _selectedFloor!.trim();

      return matchesSearch && matchesFloor;
    }).toList();

    if (filteredVideos.isEmpty) {
      return Center(
        child: Text(_selectedFloor != null && _selectedFloor != 'All Floors'
            ? 'No videos found for $_selectedFloor'
            : 'No videos found'),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore && 
            _hasMore && 
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadVideos(loadMore: true);
        }
        return true;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredVideos.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredVideos.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final video = filteredVideos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  title: Text(video['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video['description']),
                      Text('Hall: ${video['hallNumber']} - Floor: ${video['floor']}'),
                    ],
                  ),
                  onTap: () => _playVideo(video['fileId']),
                  trailing: IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () => _showQRDialog(video),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloorFilter() {
    return DropdownButton<String>(
      value: _selectedFloor,
      hint: const Text('Select Floor'),
      items: AdminService.getAvailableFloors()
          .map((floor) => DropdownMenuItem(
                value: floor,
                child: Text(floor),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedFloor = value;
        });
        debugPrint('Selected floor: $value'); // For debugging
      },
    );
  }

  void _showQRDialog(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                video['title'],
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: AppwriteService.getVideoUrl(video['fileId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Error generating QR code');
                  }
                  final videoUrl = snapshot.data!;
                  return Column(
                    children: [
                      QrImageView(
                        data: videoUrl,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scan to watch video',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playVideo(String fileId) async {
    try {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
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
      debugPrint('Video URL: $videoUrl');

      if (!mounted) return;
      
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            url: videoUrl,
            autoPlay: true,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

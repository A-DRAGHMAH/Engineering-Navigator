// ignore_for_file: deprecated_member_use

import 'package:aaup/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../common/web_view_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

// File type helpers
IconData _getFileTypeIcon(String fileType) {
  switch (fileType.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'document':
      return Icons.description;
    case 'video':
      return Icons.video_library;
    case 'presentation':
      return Icons.slideshow;
    case 'image':
      return Icons.image;
    case 'code':
      return Icons.code;
    default:
      return Icons.insert_drive_file;
  }
}

Color _getFileTypeColor(String fileType) {
  switch (fileType.toLowerCase()) {
    case 'pdf':
      return Colors.red;
    case 'document':
      return Colors.blue;
    case 'video':
      return Colors.purple;
    case 'presentation':
      return Colors.orange;
    case 'image':
      return Colors.green;
    case 'code':
      return Colors.teal;
    default:
      return Colors.grey;
  }
}

String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}

class UserStudyMaterialsPage extends StatelessWidget {
  const UserStudyMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: engineeringDepartments.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 158, 162, 201), // Deep indigo
                  Color(0xFF0d47a1), // Rich blue
                  Color(0xFF01579b), // Dark blue
                ],
              ),
            ),
          ),
          title: const Text(
            'Study Materials',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs:
                engineeringDepartments.map((dept) => Tab(text: dept)).toList(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.white,
              ],
            ),
          ),
          child: TabBarView(
            children: engineeringDepartments
                .map((dept) => _DepartmentMaterialsView(department: dept))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _DepartmentMaterialsView extends StatelessWidget {
  final String department;

  const _DepartmentMaterialsView({required this.department});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('study_materials')
          .where('department', isEqualTo: department)
          .where('isPublic', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final materials = snapshot.data!.docs;

        // Sort in memory instead
        materials.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['uploadedAt'] as Timestamp;
          final bTime = bData['uploadedAt'] as Timestamp;
          return bTime.compareTo(aTime); // descending order
        });

        if (materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No materials available for $department',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index].data() as Map<String, dynamic>;
            return _MaterialCard(material: material);
          },
        );
      },
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;

  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final fileType = material['fileType'] as String;
    final IconData typeIcon = _getFileTypeIcon(fileType);
    final Color typeColor = _getFileTypeColor(fileType);

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Show material details
            _showMaterialDetails(context);
          },
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(typeIcon, color: const Color(0xFF1565C0)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${material['course'] ?? material['department']} • ${material['year']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildActions(context),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(material['uploadedAt']),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.download, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${material['downloads'] ?? 0}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.qr_code),
          onPressed: () => _showQRDialog(context),
          tooltip: 'Show QR Code',
        ),
        _buildDownloadButton(context),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () => _openMaterial(context),
      child: const Text('Open'),
    );
  }

  void _openMaterial(BuildContext context) async {
    try {
      final url = material['url'] as String?;
      final docId = material['id']; // Make sure this ID exists

      if (url == null || url.isEmpty) {
        throw Exception('Invalid URL');
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        // First try to launch externally
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );

        // Only update if we have a valid document ID
        if (docId != null) {
          try {
            await FirebaseFirestore.instance
                .collection('study_materials')
                .doc(docId)
                .update({
              'downloads': FieldValue.increment(1),
            });
          } catch (e) {
            debugPrint('Failed to update download count: $e');
            // Don't throw - allow user to still access material
          }
        }
      } else {
        // Fallback to WebView
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              title: material['title'] ?? 'Study Material',
              url: url,
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening material: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _openMaterial(context),
          ),
        ),
      );
    }
  }

  void _showMaterialDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      _getFileTypeColor(material['fileType']).withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getFileTypeColor(material['fileType'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getFileTypeIcon(material['fileType']),
                        color: _getFileTypeColor(material['fileType']),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${material['fileType']} Document',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Department: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(material['department']),
                      ],
                    ),
                    if (material['course'] != null)
                      Row(
                        children: [
                          const Text('Course: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(material['course']),
                        ],
                      ),
                    Row(
                      children: [
                        const Text('Year: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(material['year']),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Semester: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(material['semester']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(material['description']),
                    const SizedBox(height: 16),
                    if ((material['tags'] as List?)?.isNotEmpty ?? false) ...[
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: (material['tags'] as List)
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Uploaded on ${_formatDate(material['uploadedAt'])}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        Text(
                          '${material['downloads'] ?? 0} downloads',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open'),
                      onPressed: () {
                        Navigator.pop(context);
                        _openMaterial(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                material['title'] ?? 'Study Material',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: material['url'] ?? '',
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Scan to access material',
                style: TextStyle(fontSize: 16),
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
}

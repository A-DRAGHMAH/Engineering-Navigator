// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../models/link_model.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLinksPage extends StatefulWidget {
  const AdminLinksPage({super.key});

  @override
  State<AdminLinksPage> createState() => _AdminLinksPageState();
}

class _AdminLinksPageState extends State<AdminLinksPage> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = LinkModel.linkTypes.first;
  Stream<List<LinkModel>>? _linksStream;

  @override
  void initState() {
    super.initState();
    _initLinksStream();
  }

  void _initLinksStream() {
    _linksStream = FirebaseService.getDataStream('links').map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LinkModel(
          id: doc.id,
          name: data['name'] ?? '',
          url: data['url'] ?? '',
          type: data['type'] ?? LinkModel.linkTypes.first,
          uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addLink() async {
    if (_nameController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await FirebaseService.saveData('links', null, {
        'name': _nameController.text,
        'url': _urlController.text,
        'type': _selectedType,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _urlController.clear();
    setState(() {
      _selectedType = LinkModel.linkTypes.first;
    });
  }

  Future<void> _deleteLink(String id) async {
    try {
      await FirebaseService.deleteData('links', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link deleted successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Links'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Link',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Link Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter link name...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        border: OutlineInputBorder(),
                        hintText: 'Enter URL...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Link Type',
                        border: OutlineInputBorder(),
                      ),
                      items: LinkModel.linkTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _addLink,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Link'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Current Links',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<LinkModel>>(
                stream: _linksStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final links = snapshot.data!;

                  return ListView.builder(
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      final link = links[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            LinkModel.getTypeIcon(link.type),
                            color: LinkModel.getTypeColor(link.type),
                            size: 32,
                          ),
                          title: Text(link.name),
                          subtitle: Text(link.url),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteLink(link.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
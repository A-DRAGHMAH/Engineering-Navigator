import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChatbotSettingsPage extends StatefulWidget {
  const AdminChatbotSettingsPage({super.key});

  @override
  State<AdminChatbotSettingsPage> createState() =>
      _AdminChatbotSettingsPageState();
}

class _AdminChatbotSettingsPageState extends State<AdminChatbotSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEnabled = true;
  String _selectedModel = 'gpt-3.5-turbo';
  final _maxTokensController = TextEditingController(text: '2000');
  final _temperatureController = TextEditingController(text: '0.7');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('chatbot')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _isEnabled = data['isEnabled'] ?? true;
          _selectedModel = data['model'] ?? 'gpt-3.5-turbo';
          _maxTokensController.text = (data['maxTokens'] ?? 2000).toString();
          _temperatureController.text = (data['temperature'] ?? 0.7).toString();
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('chatbot')
          .set({
        'isEnabled': _isEnabled,
        'model': _selectedModel,
        'maxTokens': int.parse(_maxTokensController.text),
        'temperature': double.parse(_temperatureController.text),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Chatbot'),
                        value: _isEnabled,
                        onChanged: (value) =>
                            setState(() => _isEnabled = value),
                      ),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Model'),
                        value: _selectedModel,
                        items: const [
                          DropdownMenuItem(
                              value: 'gpt-3.5-turbo',
                              child: Text('GPT-3.5 Turbo')),
                          DropdownMenuItem(
                              value: 'gpt-4', child: Text('GPT-4')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedModel = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxTokensController,
                        decoration:
                            const InputDecoration(labelText: 'Max Tokens'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final number = int.tryParse(value);
                          if (number == null || number < 1) {
                            return 'Invalid value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _temperatureController,
                        decoration:
                            const InputDecoration(labelText: 'Temperature'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final number = double.tryParse(value);
                          if (number == null || number < 0 || number > 1) {
                            return 'Must be between 0 and 1';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatHistory')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final totalChats = snapshot.data!.docs.length;
                  final today =
                      DateTime.now().toLocal().toString().split(' ')[0];
                  final chatsToday = snapshot.data!.docs.where((doc) {
                    final timestamp =
                        (doc.data() as Map)['timestamp'] as Timestamp?;
                    if (timestamp == null) return false;
                    return timestamp
                            .toDate()
                            .toLocal()
                            .toString()
                            .split(' ')[0] ==
                        today;
                  }).length;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Usage Statistics',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.chat),
                            title: const Text('Total Conversations'),
                            trailing: Text(
                              totalChats.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.today),
                            title: const Text('Conversations Today'),
                            trailing: Text(
                              chatsToday.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _maxTokensController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }
}

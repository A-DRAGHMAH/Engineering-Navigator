// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {} catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: const Color(0xFF2B2B2B),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2B2B2B),
              Color(0xFF3D0000),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSettingSection(
                    'System Maintenance',
                    [
                      _buildSettingTile(
                        'Backup Database',
                        'Create a backup of the system database',
                        Icons.backup,
                        () async {
                          await _performAction(
                            'Backing up database...',
                            AdminService.backupDatabase,
                          );
                        },
                      ),
                      _buildSettingTile(
                        'Clear Cache',
                        'Clear system cache and temporary files',
                        Icons.cleaning_services,
                        () async {
                          await _performAction(
                            'Clearing cache...',
                            AdminService.clearCache,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingSection(
                    'Security',
                    [
                      _buildSettingTile(
                        'Access Logs',
                        'View system access logs',
                        Icons.security,
                        () async {
                          final logs = await AdminService.getAccessLogs();
                          if (!mounted) return;
                          _showLogsDialog(context, logs);
                        },
                      ),
                      _buildSettingTile(
                        'Reset Password',
                        'Change admin password',
                        Icons.lock_reset,
                        () => _showPasswordResetDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _performAction(
    String loadingMessage,
    Future<void> Function() action,
  ) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Operation completed successfully'),
          backgroundColor: Color(0xFF8B0000),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLogsDialog(BuildContext context, List<Map<String, dynamic>> logs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2B2B),
        title: const Text('Access Logs', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text(
                  log['action'] ?? 'Unknown action',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  log['timestamp']?.toString() ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2B2B),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (newPasswordController.text.isNotEmpty) {
                await AdminService.resetPassword(newPasswordController.text);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully'),
                    backgroundColor: Color(0xFF8B0000),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

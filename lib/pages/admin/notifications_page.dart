// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminNotificationsPage extends StatefulWidget {
  final String adminId;

  const AdminNotificationsPage({
    super.key,
    required this.adminId,
  });

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedPriority = 'Normal';
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Send Notification'),
              Tab(text: 'View Notifications'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSendNotificationForm(),
            _buildNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendNotificationForm() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[100]!,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Notification',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Enter notification message',
                          prefixIcon: const Icon(Icons.message_outlined),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.priority_high),
                        ),
                        items: ['High', 'Medium', 'Normal'].map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Icon(
                                  _getPriorityIcon(priority),
                                  color: _getPriorityColor(priority),
                                ),
                                const SizedBox(width: 8),
                                Text(priority),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPriority = value!);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : _sendNotification,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                              _isSending ? 'Sending...' : 'Send Notification'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[100]!,
            Colors.white,
          ],
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification =
                  notifications[index].data() as Map<String, dynamic>;
              final id = notifications[index].id;
              final message =
                  notification['message'] as String? ?? 'No message';
              final priority = notification['priority'] as String? ?? 'normal';
              final timestamp = notification['timestamp'] as Timestamp?;
              final isRead = notification['isRead'] as bool? ?? false;

              return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        _getPriorityColor(priority).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor:
                          _getPriorityColor(priority).withOpacity(0.1),
                      child: Icon(
                        _getPriorityIcon(priority),
                        color: _getPriorityColor(priority),
                      ),
                    ),
                    title: Text(
                      message,
                      style: TextStyle(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      timestamp != null
                          ? DateFormat('MMM d, y HH:mm')
                              .format(timestamp.toDate())
                          : 'No date',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red[400],
                      onPressed: () => _deleteNotification(context, id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.warning_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _deleteNotification(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(id)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await AdminService.sendNotification(
        _messageController.text,
        _selectedPriority,
      );

      if (!mounted) return;

      _messageController.clear();
      setState(() => _selectedPriority = 'Normal');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

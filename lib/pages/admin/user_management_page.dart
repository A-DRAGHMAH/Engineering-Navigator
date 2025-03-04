// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final _emailController = TextEditingController();
  final _roles = ['Student', 'Faculty', 'Staff', 'Admin'];
  String _selectedRole = 'Student';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('User Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          return Column(
            children: [
              _buildAddUserSection(),
              Expanded(
                child:
                    users.isEmpty ? _buildEmptyState() : _buildUsersList(users),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddUserSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: _roles
                .map((role) => ButtonSegment(
                      value: role,
                      label: Text(role),
                      icon: Icon(_getRoleIcon(role)),
                    ))
                .toList(),
            selected: {_selectedRole},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _selectedRole = selection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLoading ? null : _addUser,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(_isLoading ? 'Adding...' : 'Add User'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<QueryDocumentSnapshot> users) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index].data() as Map<String, dynamic>;
        return _buildUserTile(user, users[index].id);
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, String userId) {
    final role = user['role'] as String? ?? 'Student';
    final status = user['status'] as String? ?? 'active';
    final isActive = status == 'active';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role).withOpacity(0.1),
          child: Icon(
            _getRoleIcon(role),
            color: _getRoleColor(role),
          ),
        ),
        title: Text(
          user['email'] ?? 'No email',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(role),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive,
              onChanged: (value) => _updateUserStatus(userId, value),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () => _deleteUser(userId),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'faculty':
        return Icons.school;
      case 'staff':
        return Icons.badge;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'faculty':
        return Colors.blue;
      case 'staff':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No users yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter an email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AdminService.addUser(
        email: _emailController.text,
        role: _selectedRole,
      );

      _emailController.clear();
      _showSuccess('User added successfully');
    } catch (e) {
      _showError('Error adding user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserStatus(String userId, bool isActive) async {
    try {
      await AdminService.updateUserStatus(userId, isActive);
      _showSuccess('User status updated');
    } catch (e) {
      _showError('Error updating user status: $e');
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await AdminService.deleteUser(userId);
      _showSuccess('User deleted successfully');
    } catch (e) {
      _showError('Error deleting user: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

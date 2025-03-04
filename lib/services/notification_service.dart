import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isShowingNotification = false;

  static Future<void> initialize() async {
    debugPrint('NotificationService: Initializing...');

    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty && !_isShowingNotification) {
        final notification = snapshot.docs.first.data();
        _showBannerNotification(
          title: notification['title'] ?? 'New Notification',
          body: notification['body'] ?? '',
        );
      }
    });
  }

  static void _showBannerNotification({
    required String title,
    required String body,
  }) {
    if (_isShowingNotification || navigatorKey.currentContext == null) return;

    _isShowingNotification = true;

    final scaffoldMessenger =
        ScaffoldMessenger.of(navigatorKey.currentContext!);

    scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(16),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        actions: [
          TextButton(
            onPressed: () {
              scaffoldMessenger.hideCurrentMaterialBanner();
              _isShowingNotification = false;
              Navigator.pushNamed(
                  navigatorKey.currentContext!, '/notifications');
            },
            child: const Text(
              'VIEW',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        elevation: 5,
        leadingPadding: EdgeInsets.zero,
      ),
    );

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (_isShowingNotification) {
        scaffoldMessenger.hideCurrentMaterialBanner();
        _isShowingNotification = false;
      }
    });
  }
}

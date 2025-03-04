class NotificationModel {
  final String id;
  final String message;
  final String priority;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.message,
    required this.priority,
    required this.timestamp,
  });

  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      case 'low':
        return 'green';
      default:
        return 'grey';
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class UserCalendarPage extends StatefulWidget {
  const UserCalendarPage({super.key});

  @override
  State<UserCalendarPage> createState() => _UserCalendarPageState();
}

class _UserCalendarPageState extends State<UserCalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _showAllEvents = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadEvents();
  }

  void _loadEvents() {
    // Load academic calendar events
    final academicEvents = [
      _createEvent(
        'Registration for Fall 2024/2025',
        DateTime(2024, 9, 9),
        DateTime(2024, 10, 12),
        'Registration',
      ),
      _createEvent(
        'Change Major Period',
        DateTime(2024, 9, 15),
        DateTime(2024, 10, 12),
        'Academic',
      ),
      _createEvent(
        'Faculty Members Summer Vacation Ends',
        DateTime(2024, 10, 6),
        DateTime(2024, 10, 6),
        'Faculty',
      ),
      _createEvent(
        'Orientation for New Students - Jenin Campus',
        DateTime(2024, 10, 13),
        DateTime(2024, 10, 13),
        'Orientation',
      ),
      _createEvent(
        'Add & Drop without "W"',
        DateTime(2024, 10, 13),
        DateTime(2024, 10, 19),
        'Academic',
      ),
      _createEvent(
        'Start of Fall Semester 2024/2025 and Classes Begin',
        DateTime(2024, 10, 13),
        DateTime(2024, 10, 13),
        'Academic',
      ),
      _createEvent(
        'Orientation for New Students - Ramallah Campus',
        DateTime(2024, 10, 15),
        DateTime(2024, 10, 15),
        'Orientation',
      ),
      _createEvent(
        'Last day to submit the Incomplete marks',
        DateTime(2024, 10, 17),
        DateTime(2024, 10, 17),
        'Academic',
      ),
      _createEvent(
        'Last Day to Postpone Fall Semester',
        DateTime(2024, 11, 14),
        DateTime(2024, 11, 14),
        'Academic',
      ),
      _createEvent(
        'Independence Declaration Day - Holiday',
        DateTime(2024, 11, 15),
        DateTime(2024, 11, 15),
        'Holiday',
      ),
      _createEvent(
        'First examination period',
        DateTime(2024, 11, 24),
        DateTime(2024, 12, 5),
        'Exam',
      ),
      _createEvent(
        'Mid term examination period',
        DateTime(2024, 12, 2),
        DateTime(2024, 12, 31),
        'Exam',
      ),
      _createEvent(
        'Last day to submit the first exam marks',
        DateTime(2024, 12, 8),
        DateTime(2024, 12, 8),
        'Academic',
      ),
      _createEvent(
        'Early Registration for Spring Semester 2024/2025',
        DateTime(2024, 12, 15),
        DateTime(2025, 2, 20),
        'Registration',
      ),
      _createEvent(
        'Christmas (Western) - Holiday',
        DateTime(2024, 12, 25),
        DateTime(2024, 12, 25),
        'Holiday',
      ),
      _createEvent(
        'Second examination period',
        DateTime(2024, 12, 29),
        DateTime(2025, 1, 14),
        'Exam',
      ),
      _createEvent(
        'New Year\'s Day - Holiday',
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 1),
        'Holiday',
      ),
      _createEvent(
        'Accepting Applications for Admission for Spring Semester 2024/2025',
        DateTime(2025, 1, 2),
        DateTime(2025, 1, 2),
        'Admission',
      ),
      _createEvent(
        'Last day to submit the Mid-term exam marks',
        DateTime(2025, 1, 5),
        DateTime(2025, 1, 5),
        'Academic',
      ),
      _createEvent(
        'Christmas (Eastern) - Holiday',
        DateTime(2025, 1, 7),
        DateTime(2025, 1, 7),
        'Holiday',
      ),
      _createEvent(
        'Last day to submit the second exams marks',
        DateTime(2025, 1, 19),
        DateTime(2025, 1, 19),
        'Academic',
      ),
      _createEvent(
        'Al-Esraa\' & Al-Me\'raaj - Holiday*',
        DateTime(2025, 1, 28),
        DateTime(2025, 1, 28),
        'Holiday',
      ),
      _createEvent(
        'Last day to submit all course work',
        DateTime(2025, 2, 5),
        DateTime(2025, 2, 5),
        'Academic',
      ),
      _createEvent(
        'Last day of classes',
        DateTime(2025, 2, 6),
        DateTime(2025, 2, 6),
        'Academic',
      ),
      _createEvent(
        'Last day to drop course(s) or semester with "W"',
        DateTime(2025, 2, 6),
        DateTime(2025, 2, 6),
        'Academic',
      ),
      _createEvent(
        'Final Exams Period',
        DateTime(2025, 2, 8),
        DateTime(2025, 2, 20),
        'Exam',
      ),
      _createEvent(
        'Fall break',
        DateTime(2025, 2, 23),
        DateTime(2025, 3, 6),
        'Break',
      ),
      _createEvent(
        'Last day to submit final exam marks',
        DateTime(2025, 2, 24),
        DateTime(2025, 2, 24),
        'Academic',
      ),
      _createEvent(
        'Registration for Spring Semester 2024/2025',
        DateTime(2025, 2, 24),
        DateTime(2025, 3, 8),
        'Registration',
      ),
    ];

    // Create a map to store all events
    Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

    // First, add academic calendar events
    for (var event in academicEvents) {
      final startTime = (event['startTime'] as Timestamp).toDate();
      final endTime = (event['endTime'] as Timestamp).toDate();
      final dateKey = DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
      );
      if (newEvents[dateKey] == null) {
        newEvents[dateKey] = [];
      }
      newEvents[dateKey]!.add({
        ...event,
        'startTime': startTime,
        'endTime': endTime,
        'isAcademicCalendar': true,
      });
    }

    // Listen to admin events
    FirebaseFirestore.instance
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      // Create a copy of academic events
      Map<DateTime, List<Map<String, dynamic>>> combinedEvents =
          Map.from(newEvents);

      // Add admin events
      for (var doc in snapshot.docs) {
        final event = doc.data();
        final Timestamp timestamp = event['startTime'];
        final startTime = timestamp.toDate();

        final dateKey = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
        );

        if (combinedEvents[dateKey] == null) {
          combinedEvents[dateKey] = [];
        }

        combinedEvents[dateKey]!.add({
          ...event,
          'id': doc.id,
          'startTime': startTime,
          'endTime': (event['endTime'] as Timestamp).toDate(),
          'isAcademicCalendar': false,
        });
      }

      if (mounted) {
        setState(() {
          _events = combinedEvents;
        });
      }
    });
  }

  Map<String, dynamic> _createEvent(
    String title,
    DateTime startTime,
    DateTime endTime,
    String type,
  ) {
    return {
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type,
      'isAcademicCalendar': true,
    };
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAllEvents = !_showAllEvents;
              });
            },
            icon: Icon(
              _showAllEvents
                  ? Icons.calendar_view_day
                  : Icons.calendar_view_month,
              color: Colors.white,
            ),
            label: Text(
              _showAllEvents ? 'Show Selected Day' : 'Show All Events',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4,
            child: TableCalendar(
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _showAllEvents = false;
                });
              },
              calendarStyle: const CalendarStyle(
                markersMaxCount: 3,
                markerSize: 8,
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _showAllEvents
                  ? _getAllEvents().length
                  : _getEventsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                final event = _showAllEvents
                    ? _getAllEvents()[index]
                    : _getEventsForDay(_selectedDay)[index];
                return _buildEventTile(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return Icons.celebration;
      case 'exam':
        return Icons.assignment;
      case 'registration':
        return Icons.app_registration;
      case 'academic':
        return Icons.school;
      case 'orientation':
        return Icons.people;
      case 'break':
        return Icons.beach_access;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return Colors.red;
      case 'exam':
        return Colors.orange;
      case 'registration':
        return Colors.blue;
      case 'academic':
        return Colors.green;
      case 'orientation':
        return Colors.purple;
      case 'break':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getAllEvents() {
    final allEvents = <Map<String, dynamic>>[];
    _events.values.forEach(allEvents.addAll);

    allEvents.sort((a, b) {
      final DateTime aTime = a['startTime'];
      final DateTime bTime = b['startTime'];
      return aTime.compareTo(bTime);
    });

    return allEvents;
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    final DateTime startTime = event['startTime'];
    final DateTime? endTime = event['endTime'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          _getEventIcon(event['type'] ?? ''),
          color: _getEventColor(event['type'] ?? ''),
        ),
        title: Text(
          event['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(startTime)),
            if (endTime != null && endTime != startTime)
              Text('Until: ${DateFormat('MMM dd, yyyy').format(endTime)}'),
            if (event['location'] != null)
              Text('Location: ${event['location']}'),
            if (event['type'] != null)
              Text(
                event['type'],
                style: TextStyle(
                  color: _getEventColor(event['type']),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

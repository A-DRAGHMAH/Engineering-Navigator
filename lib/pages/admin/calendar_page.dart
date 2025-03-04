import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:table_calendar/table_calendar.dart';
import '../../models/event_model.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCalendarPage extends StatefulWidget {
  const AdminCalendarPage({super.key});

  @override
  State<AdminCalendarPage> createState() => _AdminCalendarPageState();
}

class _AdminCalendarPageState extends State<AdminCalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = EventModel.eventTypes.first;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addEvent() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final startDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _endTime.hour,
        _endTime.minute,
      );

      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'type': _selectedType,
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'isPublic': true,
      };

      await FirebaseService.saveData('events', null, eventData);

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Event Added',
        'body': 'New event: ${_titleController.text}',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'event',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedType = EventModel.eventTypes.first;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now();
    });
  }

  Widget _buildEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getDataStream('events'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data?.docs ?? [];
        if (events.isEmpty) {
          return const Center(
            child: Text('No events scheduled'),
          );
        }

        return Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              final startTime = (event['startTime'] as Timestamp).toDate();
              final endTime = (event['endTime'] as Timestamp).toDate();

              return ListTile(
                title: Text(event['title']),
                subtitle: Text(
                  '${DateFormat('MMM d, y').format(startTime)} at ${DateFormat('h:mm a').format(startTime)}\n'
                  'Until: ${DateFormat('MMM d, y').format(endTime)}\n'
                  'Location: ${event['location']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseService.deleteData(
                      'events',
                      events[index].id,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add Event for ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(),
                      ),
                      items: EventModel.eventTypes.map((type) {
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectTime(context, true),
                            icon: const Icon(Icons.access_time),
                            label: Text('Start: ${_startTime.format(context)}'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectTime(context, false),
                            icon: const Icon(Icons.access_time),
                            label: Text('End: ${_endTime.format(context)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Enter event details...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _addEvent,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Event'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }
}

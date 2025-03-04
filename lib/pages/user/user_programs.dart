import 'package:flutter/material.dart';
import '../../models/educational_program.dart';
import '../../services/user_service.dart';

class UserProgramsPage extends StatefulWidget {
  const UserProgramsPage({super.key});

  @override
  State<UserProgramsPage> createState() => _UserProgramsPageState();
}

class _UserProgramsPageState extends State<UserProgramsPage> {
  List<EducationalProgram> _programs = [];
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final programs = await UserService.getEducationalPrograms();
    setState(() {
      _programs = programs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrograms = _selectedSpecialty == null
        ? _programs
        : _programs
            .where((program) => program.specialty == _selectedSpecialty)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Programs'),
        actions: [
          DropdownButton<String>(
            value: _selectedSpecialty,
            hint: const Text('Filter by Specialty'),
            onChanged: (value) {
              setState(() {
                _selectedSpecialty = value;
              });
            },
            items: <String>[
              'Architectural Engineering',
              'Biomedical Equipment Engineering',
              'Civil Engineering',
              'Computer Systems Engineering',
              'Cyber Security Engineering',
              'Electrical Engineering',
              'Mechatronics Engineering',
              'Communications Engineering',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredPrograms.length,
        itemBuilder: (context, index) {
          final program = filteredPrograms[index];
          return ListTile(
            title: Text(program.title),
            subtitle: Text(program.description),
          );
        },
      ),
    );
  }
}

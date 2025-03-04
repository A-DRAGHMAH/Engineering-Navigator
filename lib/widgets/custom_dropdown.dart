import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final ValueChanged<String?> onChanged;
  final List<String> items;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
} 
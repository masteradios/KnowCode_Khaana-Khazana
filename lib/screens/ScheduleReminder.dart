import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helper/helperFunctions.dart';

class ScheduleReminderScreen extends StatefulWidget {
  final String audioPath;

  const ScheduleReminderScreen({Key? key, required this.audioPath})
      : super(key: key);

  @override
  _ScheduleReminderScreenState createState() => _ScheduleReminderScreenState();
}

class _ScheduleReminderScreenState extends State<ScheduleReminderScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  void _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    scheduleNotification(
      _titleController.text,
      'Reminder',

      _selectedDateTime!,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reminder Title'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Enter reminder title'),
            ),
            const SizedBox(height: 20),
            const Text('Select Date & Time'),
            TextButton.icon(
              onPressed: _selectDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDateTime == null
                    ? 'Pick Date & Time'
                    : DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

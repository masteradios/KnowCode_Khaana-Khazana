import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class DoctorVisitPage extends StatefulWidget {
  const DoctorVisitPage({super.key});

  @override
  State<DoctorVisitPage> createState() => _DoctorVisitPageState();
}

class _DoctorVisitPageState extends State<DoctorVisitPage> {
  final TextEditingController _doctorName = TextEditingController();
  final TextEditingController _doctorSpeciality = TextEditingController();
  final TextEditingController _doctorAddress = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> dementiaConditions = [
    'Alzheimer\'s Disease',
    'Vascular Dementia',
    'Lewy Body Dementia',
    'Frontotemporal Dementia',
    'Mixed Dementia',
    'Parkinson\'s Disease Dementia',
    'Creutzfeldt-Jakob Disease',
    'Normal Pressure Hydrocephalus',
    'Huntington\'s Disease',
    'Wernicke-Korsakoff Syndrome'
  ];

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> scheduleVisit() async {
    if (_selectedDate == null || _selectedTime == null ||_doctorName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Combine selected date and time
    final DateTime visitDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Schedule the notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'scheduled_channel',
        title: 'Doctor Visit Reminder',
        body: 'You have a visit scheduled with Dr. ${_doctorName.text}.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: visitDateTime),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visit scheduled for ${DateFormat('dd MMMM yyyy hh:mm a').format(visitDateTime)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log a Visit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Doctor\'s Name', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _doctorName,
                decoration: InputDecoration(hintText: 'Enter first name'),
              ),
              SizedBox(height: 16),

              Text('Doctor\'s Speciality', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _doctorSpeciality,
                decoration: InputDecoration(hintText: 'MD, Neurologist, or Psychiatrist'),
              ),
              SizedBox(height: 16),

              Text('Doctor\'s Address', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _doctorAddress,
                decoration: InputDecoration(hintText: 'Enter Address'),
              ),
              SizedBox(height: 16),

              Text('Enter Date of Visit', style: TextStyle(fontSize: 18)),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text('Enter Time of Visit', style: TextStyle(fontSize: 18)),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context),
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: (){
                  scheduleVisit();
                },
                child: Text('Schedule Visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

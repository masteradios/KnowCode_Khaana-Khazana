import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';

class DoctorVisitPage extends StatefulWidget {
 // Pass the user ID to this page

  const DoctorVisitPage({super.key, });

  @override
  State<DoctorVisitPage> createState() => _DoctorVisitPageState();
}

class _DoctorVisitPageState extends State<DoctorVisitPage> {
  final TextEditingController _doctorName = TextEditingController();
  final TextEditingController _doctorSpeciality = TextEditingController();
  final TextEditingController _doctorAddress = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _selectTime(BuildContext context) async {
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

  Future<void> _logVisitDetails(String userId) async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _doctorName.text.isEmpty ||
        _doctorSpeciality.text.isEmpty ||
        _doctorAddress.text.isEmpty) {
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

    // Create the visit data
    final visitData = {
      'doctorName': _doctorName.text,
      'doctorSpeciality': _doctorSpeciality.text,
      'doctorAddress': _doctorAddress.text,
      'visitDateTime': visitDateTime.toIso8601String(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Save to Firestore under the user's docvisits collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('docvisits')
          .add(visitData);

      // Schedule the notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'scheduled_channel',
          title: 'Doctor Visit Reminder',
          body: 'You have a visit scheduled with Dr. ${_doctorName.text}.',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(date: visitDateTime,preciseAlarm: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Visit logged and scheduled for ${DateFormat('dd MMMM yyyy hh:mm a').format(visitDateTime)}',
          ),
        ),
      );
      Navigator.of(context).pop(true);  // Passing true to indicate an update


      // Clear the fields after successful submission
      _doctorName.clear();
      _doctorSpeciality.clear();
      _doctorAddress.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log visit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId=Provider.of<UserProvider>(context).userModel!.id;
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
                  _logVisitDetails(userId);
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

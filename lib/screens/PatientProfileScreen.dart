import 'package:alz/helper/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helper/diseases.dart';

class PatientProfilePage extends StatefulWidget {
  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  String? _selectedCondition;

  DateTime? _selectedDate;

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
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

  void submit(){
    FirebaseServices().signUpUser(email: 'abc@gmail.com', password: '123456');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Text('First Name',style: TextStyle(fontSize: 18),),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(

                  hintText: 'Enter first name',
                ),
              ),
              SizedBox(height: 16),

              Text('Last Name',style: TextStyle(fontSize: 18),),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(

                  hintText: 'Enter last name',
                ),
              ),
              SizedBox(height: 16),

              Text('Relationship to the Caretaker',style: TextStyle(fontSize: 18),),
              TextField(
                controller: _relationshipController,
                decoration: InputDecoration(

                  hintText: 'Enter relationship (e.g., Son, Daughter)',
                ),
              ),
              SizedBox(height: 16),

              Text('Month and Year of Birth',style: TextStyle(fontSize: 18),),
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
                            ? 'Select Date of Birth'
                            : DateFormat('MMMM yyyy').format(_selectedDate!),
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.calendar_month)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),


              Text('Disease Diagnosed',style: TextStyle(fontSize: 18),),
              DropdownButtonFormField(
                value: _selectedCondition,
                items: dementiaConditions.map((condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCondition = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select a condition',
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

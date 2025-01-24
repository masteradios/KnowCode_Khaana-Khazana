import 'package:flutter/material.dart';
class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          TextField(decoration: InputDecoration(hintText: 'Enter a Title',),),
          TextField(decoration: InputDecoration(hintText: 'Enter a Description',),),
          ElevatedButton(onPressed: (){

            showTimePicker(context: context, initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));

          }, child: Text('Set Time'))

        ],
      ),

    );
  }
}

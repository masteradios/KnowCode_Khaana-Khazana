import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../helper/helperFunctions.dart';

class AlarmHomePage extends StatefulWidget {
  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  final AudioRecorder _record = AudioRecorder();
  String? recordedFilePath;
  DateTime? selectedTime;


  @pragma('vm:entry-point')
  void playAudioAlarm() async {
    scheduleNotification("Alarm","dawda",selectedTime!);
    final dir = await getApplicationDocumentsDirectory();
    final customAudioPath = "${dir.path}/custom_audiololo.mp3";

    final player = AudioPlayer();
    await player.setFilePath(customAudioPath);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Alarm with Sound")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => recordAudio(),
              child: Text("Record Custom Sound"),
            ),
            if (recordedFilePath != null)
              Text("Recorded Sound Path: $recordedFilePath"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => pickTime(context),
              child: Text("Pick Reminder Time"),
            ),
            if (selectedTime != null)
              Text("Selected Time: ${selectedTime.toString()}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => scheduleAlarm(),
              child: Text("Set Reminder with Custom Sound"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> recordAudio() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/custom_audiololo.mp3";
    RecordConfig config=RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );
    if (await _record.hasPermission()) {
      await _record.start(
        config,path: filePath,

      );

      await Future.delayed(Duration(seconds: 5)); // Record for 5 seconds
      await _record.stop();
      setState(() {
        recordedFilePath = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Audio Recorded Successfully!"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Microphone Permission Denied"),
      ));
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {});
    }
  }

  Future<void> scheduleAlarm() async {
    if (selectedTime != null && recordedFilePath != null) {


      Workmanager().registerPeriodicTask('alarmClock', 'alarmClock',inputData: {

        'title':"something"

      },frequency: Duration(minutes: 30));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Alarm Scheduled!"),
      ));


      final int alarmId = 10; // Unique ID for the alarm
      await AndroidAlarmManager.oneShotAt(
        selectedTime!, // Alarm time
        alarmId,
        playAudioAlarm,

        wakeup: true,
        rescheduleOnReboot: true,
      );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please record audio and select a time first."),
      ));
    }
  }
}



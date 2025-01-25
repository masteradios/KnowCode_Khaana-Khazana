import 'package:alarm/alarm.dart';
import 'package:alz/pages.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({Key? key}) : super(key: key);

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool isRecording = false;
  String? recordedAudioPath;
  DateTime selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> pickDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (selectedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/alarm_sound_${DateTime.now().millisecondsSinceEpoch}.m4a';
      RecordConfig config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      await _recorder.start(config, path: path);
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      isRecording = false;
      recordedAudioPath = path;
    });
  }

  Future<void> saveAlarm() async {
    if (recordedAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record an alarm sound first.')),
      );
      return;
    }

    final alarmSettings = AlarmSettings(
      id: DateTime.now().millisecondsSinceEpoch % 10000 + 1,
      dateTime: selectedDateTime,
      loopAudio: true,
      vibrate: true,
      assetAudioPath: recordedAudioPath!,
      notificationSettings: NotificationSettings(
        title: _titleController.text.trim(),
        body: _descriptionController.text.trim(),
        stopButton: 'Stop the alarm',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm has been set!')),
    );
    Provider.of<PageProvider>(context, listen: false).setIndex(2);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDateTime);

    String day =
        DateFormat('EEEE').format(selectedDateTime); // Day name, e.g., Monday
    String time = DateFormat('hh:mm a').format(selectedDateTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Title of the Reminder', style: TextStyle(fontSize: 18)),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: 'Enter Title'),
          ),
          SizedBox(height: 16),
          Text('Description', style: TextStyle(fontSize: 18)),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(hintText: 'Enter Description'),
          ),
          SizedBox(height: 16),
          Text('Enter Time of Reminder', style: TextStyle(fontSize: 18)),
          InkWell(
            onTap: () => pickDateTime(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('$formattedDate ', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('$day ', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('$time ', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  Icon(Icons.access_time),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          const SizedBox(height: 16),
          if (isRecording)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: stopRecording,
                child: const Text('Stop Recording'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: startRecording,
                child: const Text('Record Alarm Sound'),
              ),
            ),
          const SizedBox(height: 16),
          if (recordedAudioPath != null)
            Text('Recorded Audio: ${recordedAudioPath!.split('/').last}'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: saveAlarm,
              child: const Text('Save Alarm'),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<AlarmSettings> alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final loadedAlarms = await Alarm.getAlarms();
    setState(() {
      alarms = loadedAlarms;
    });
  }

  Future<void> _deleteAlarm(int id) async {
    await Alarm.stop(id);
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          child: Icon(Iconsax.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return AddAlarmScreen();
            }));
          }),
      body: alarms.isEmpty
          ? const Center(
              child: Text('No alarms scheduled.'),
            )
          : ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return ListTile(
                  title: Text(
                    '${alarm.dateTime.hour.toString().padLeft(2, '0')}:${alarm.dateTime.minute.toString().padLeft(2, '0')} - ${alarm.dateTime.toLocal()}'
                        .split(' ')[0],
                  ),
                  subtitle: Text(alarm.notificationSettings.title ?? 'Alarm'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteAlarm(alarm.id),
                  ),
                );
              },
            ),
    );
  }
}

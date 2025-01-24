import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordAudioScreen extends StatefulWidget {
  final Function(String) onAudioRecorded;

  const RecordAudioScreen({Key? key, required this.onAudioRecorded})
      : super(key: key);

  @override
  _RecordAudioScreenState createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;

  Future<void> _startRecording() async {
    final directory = await getExternalStorageDirectory();
    _filePath = '${directory!.path}/custom_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
    RecordConfig config=RecordConfig(encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,);
    if (await _record.hasPermission()) {
      await _record.start(config,path: _filePath!);
      print(_filePath);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _record.stop();
      setState(() {
        _isRecording = false;
      });

      if (_filePath != null) {
        widget.onAudioRecorded(_filePath!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Reminder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_off,
              color: _isRecording ? Colors.red : Colors.grey,
              size: 100,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? (){
                _stopRecording();
              } : (){
                _startRecording();
              },
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            if (_filePath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Audio saved at: $_filePath',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

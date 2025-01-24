import 'package:record/record.dart';

import 'package:path_provider/path_provider.dart';

Future<void> recordAudio(String fileName) async {
  final record = AudioRecorder();

  if (await record.hasPermission()) {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName.mp3';
  RecordConfig config=RecordConfig(encoder: AudioEncoder.aacLc,
    bitRate: 128000,
    sampleRate: 44100,);
    await record.start(
      config,
      path: filePath,

    );

    print('Recording started. File will be saved at: $filePath');
  }
}

Future<void> stopRecording() async {
  final record = AudioRecorder();
  if (await record.isRecording()) {
    await record.stop();
    print('Recording stopped');
  }
}

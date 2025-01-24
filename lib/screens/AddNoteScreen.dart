import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  File? _selectedImage;
  String? _audioPath;
  bool isRecording = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      String path = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      RecordConfig config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      await _audioRecorder.start(config, path: path);
      setState(() {
        isRecording = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission denied')),
      );
    }
  }

  Future<void> _stopRecording() async {
    String? path = await _audioRecorder.stop();
    setState(() {
      _audioPath = path;
      isRecording = false;
    });
  }

  Future<String> _uploadFileToFirebase(String userId, File file, String folder) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    Reference ref = FirebaseStorage.instance.ref('$userId/$folder/$fileName');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveNote(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      String? imageUrl, audioUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadFileToFirebase(userId, _selectedImage!, "images");
      }

      if (_audioPath != null) {
        audioUrl = await _uploadFileToFirebase(userId, File(_audioPath!), "audio");
      }

      final newNote = {
        'userId': userId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now(),
      };

      await FirebaseFirestore.instance.collection('notes').add(newNote);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New note added: ${newNote['title']}')),
      );

      Navigator.pop(context); // Close progress dialog
      Navigator.pop(context, newNote); // Close the AddNoteScreen
    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).userModel!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
      ),
      body: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                CustomTextField(
                  controller: _titleController,
                  label: 'Title',
                ),
                SizedBox(height: 20),
                Text("Journal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                ),
                SizedBox(height: 20),
                Text("Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                Container(
                  color: Colors.white,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.red, size: 30),
                        onPressed: isRecording ? _stopRecording : _startRecording,
                      ),
                      if (_audioPath != null) ...[
                        const SizedBox(width: 16), // Spacing between the icons
                        Icon(Icons.play_arrow, color: Colors.blue, size: 30),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text("Memory", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    children: [
                      _selectedImage != null
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          _selectedImage!,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Capture Image'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveNote(user.id);
                    },
                    child: const Text('Save Note'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
        ),
      ),
    );
  }
}

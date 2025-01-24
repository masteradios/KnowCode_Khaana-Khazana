import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class FaceCheckPage extends StatefulWidget {
  @override
  _FaceCheckPageState createState() => _FaceCheckPageState();
}

class _FaceCheckPageState extends State<FaceCheckPage> {
  File? _patientImage;
  String _resultMessage = '';

  final ImagePicker _picker = ImagePicker();

  // Simulate backend response
  Future<void> _checkFaceSimilarity() async {
    await Future.delayed(Duration(seconds: 2));

    setState(() {

      _resultMessage = 'The person is Sarah, your daughter.';

      // _resultMessage = 'Patient does not know this person.';
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _patientImage = File(pickedFile.path);
      });
      // Simulate the image comparison check
      _checkFaceSimilarity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Face Similarity Check"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header with large, modern font
            Text(
              'Face Similarity Check',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 20),

            // Image Picker Button with rounded corners and gradient effect
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
              child: Text(
                _patientImage == null ? 'Take a Photo' : 'Retake Photo',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),

            // Display the selected image with a modern circular border and shadow
            _patientImage == null
                ? CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.camera_alt, size: 60, color: Colors.deepPurpleAccent),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                _patientImage!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Simulated stock image in a card with soft shadow
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/stock_person.jpg', // Add a stock image to the assets folder
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Result Message with modern container style
            _resultMessage.isEmpty
                ? CircularProgressIndicator()
                : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: _resultMessage.contains('does not') ? Colors.redAccent : Colors.greenAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  _resultMessage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../pages.dart';

class ImageRecognizer extends StatefulWidget {
  @override
  _ImageRecognizerState createState() => _ImageRecognizerState();
}

class _ImageRecognizerState extends State<ImageRecognizer> {
  File? _image;
  bool _loading = false;
  String? _result;

  Future<void> _getImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _result = null; // Reset result when a new image is selected
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      _loading = true;
    });

    final url = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', url)
      ..fields['save_txt'] = 'T'
      ..files.add(await http.MultipartFile.fromPath('myfile', _image!.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      setState(() {
        _result = response.body;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _loading = false;
      });
    }
  }

  Widget _buildRecognitionResult() {
    if (_result != null) {
      final decodedResult = jsonDecode(_result!);
      final List<dynamic> results = decodedResult['results'];

      return Card(
        margin: const EdgeInsets.all(16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recognition Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...results.map((result) {
                final String name = result['name'];
                final double confidence = result['confidence'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    '$name - Confidence: ${confidence.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Placeholder for uploaded image or upload prompt
                  _image == null
                      ? Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'No Image Uploaded',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                      : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recognition results
                  _buildRecognitionResult(),
                  const SizedBox(height: 20),

                  // Buttons for taking a picture or selecting from the gallery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => _getImage(ImageSource.camera),

                        child: Text('Take Picture'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _getImage(ImageSource.gallery),
                        child: Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recognize Image Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _image != null ? _uploadImage : null,
                      icon: Icon(Icons.search_rounded),
                      label: Text('Recognize Image'),
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

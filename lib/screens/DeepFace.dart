import 'dart:io';
import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../pages.dart';

class FaceCheckPage extends StatefulWidget {
  const FaceCheckPage({super.key});

  @override
  _FaceCheckPageState createState() => _FaceCheckPageState();
}

class _FaceCheckPageState extends State<FaceCheckPage> {
  File? _patientImage;
  String _resultMessage = '';
  final ImagePicker _picker = ImagePicker();
  bool _loading=false;
   // Example user ID

  Future<void> _checkFaceSimilarity(String userId) async {
    print('user ka id'+userId);

    if (_patientImage == null) {
      setState(() {
        _resultMessage = "Please select an image first.";
      });
      return;
    }

    try {
      setState(() {
        _loading=true;
      });
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/check_relation"));
      request.fields['userId'] = userId;
      request.files.add(
        http.MultipartFile(
          'image',
          _patientImage!.openRead(),
          await _patientImage!.length(),
          filename: _patientImage!.path.split('/').last,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          _resultMessage = decodedResponse["message"] ?? "Unknown response.";
        });
      } else {
        setState(() {
          _resultMessage = "Failed to check face similarity. (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = "Error occurred: $e";
      });
    }
    setState(() {
      _loading=false;
    });
  }



  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _patientImage = File(pickedFile.path);
        _resultMessage = "";
        print('uploded '+_patientImage!.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserProvider>(context).userModel!;
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Who are you looking for ?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 20),
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
            // Image Picker Button
            ElevatedButton(
              onPressed: (){
                _showImageSourceDialog();
              },
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
                style: TextStyle(fontSize: 18,color: Colors.white),
              ),
            ),
            SizedBox(height: 20),


            ElevatedButton(
              onPressed: (){
                _checkFaceSimilarity(userModel.id);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Check Relation', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),

            // Result Message
            _resultMessage.isEmpty
                ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
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
                      "INPUT A IMAGE FOR DESCRIPTION",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
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

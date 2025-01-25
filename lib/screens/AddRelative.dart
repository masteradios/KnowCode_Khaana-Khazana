
import 'dart:convert';
import 'dart:io';
import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:alz/screens/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';

import '../pages.dart';

class AddRelativeScreen extends StatefulWidget {
  @override
  _AddRelativeScreenState createState() => _AddRelativeScreenState();
}

class _AddRelativeScreenState extends State<AddRelativeScreen> {
  List<RelativeWidget> relatives = [RelativeWidget(key: UniqueKey())];
  bool _isLoading=false;

  void _addRelative() {
    setState(() {
      relatives.add(RelativeWidget(key: UniqueKey()));
    });
  }

  Future<void> _uploadAll(String userId) async {
    setState(() {
      _isLoading=true;

    });
    print("sending ");
    for (var relativeWidget in relatives) {
      if (relativeWidget.state != null) {
        await relativeWidget.state!._upload(FirebaseAuth.instance.currentUser!.uid);
      }

    }
    setState(() {
      _isLoading=false;
    });
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_){
      return HomeScreen();
    }), (route)=>false);
  }

  @override
  Widget build(BuildContext context) {
    UserModel user=Provider.of<UserProvider>(context).userModel!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Relative'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: relatives.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: relatives[index],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: (){
                    _addRelative();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Add More'),
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    print("user id${user.id}" );
                    _uploadAll(user.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RelativeWidget extends StatefulWidget {
  RelativeWidget({Key? key}) : super(key: key);

  _RelativeWidgetState? state;

  @override
  _RelativeWidgetState createState() {
    state = _RelativeWidgetState();
    return state!;
  }
}

class _RelativeWidgetState extends State<RelativeWidget> {
  String? relationship;
  File? uploadedImage;
  String? resultMessage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Image picker function with dialog to choose source
  Future<void> _pickImage() async {
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
                onTap: () async {
                  Navigator.pop(context); // Close the dialog
                  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      uploadedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      uploadedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _upload(String userId) async {
    if (relationship == null || relationship!.isEmpty) {
      setState(() {
        resultMessage = "Relationship cannot be empty.";
      });
      return;
    }

    if (uploadedImage == null) {
      setState(() {
        resultMessage = "Please upload an image.";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      resultMessage = null; // Clear previous messages
    });

    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/upload"));
      request.fields['userId'] = userId;
      request.fields['label'] = relationship!;
      request.files.add(
        http.MultipartFile(
          'image',
          uploadedImage!.openRead(),
          await uploadedImage!.length(),
          filename: uploadedImage!.path.split('/').last,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          resultMessage = decodedResponse["message"] ?? "Image uploaded successfully.";
        });
      } else {
        setState(() {
          resultMessage = "Failed to upload image. (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "Error occurred: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              dashPattern: [6, 3],
              strokeWidth: 2,
              child: InkWell(
                onTap: _pickImage, // Open dialog on tap
                child: Container(
                  width: double.infinity,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: uploadedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      uploadedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                      SizedBox(height: 8.0),
                      Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  relationship = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            if (_isUploading)
              CircularProgressIndicator()
            else if (resultMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  resultMessage!,
                  style: TextStyle(
                    color: resultMessage == "Upload successful!" ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


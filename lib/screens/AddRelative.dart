// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../pages.dart';
// class AddRelativeScreen extends StatefulWidget {
//   const AddRelativeScreen({super.key});
//
//   @override
//   State<AddRelativeScreen> createState() => _AddRelativeScreenState();
// }
//
// class _AddRelativeScreenState extends State<AddRelativeScreen> {
//
//   File? _patientImage;
//   String _resultMessage = '';
//   final ImagePicker _picker=ImagePicker();
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//
//     if (pickedFile != null) {
//       setState(() {
//         _patientImage = File(pickedFile.path);
//         _resultMessage = "";
//         print('uploded '+_patientImage!.path);
//       });
//     }
//   }
//
//   void _showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Choose Image Source"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text("Camera"),
//                 onTap: () {
//                   Navigator.pop(context); // Close the dialog
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text("Gallery"),
//                 onTap: () {
//                   Navigator.pop(context); // Close the dialog
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//   Future<void> _uploadImage(String userId) async {
//
//     final ImagePicker _picker = ImagePicker();
//     if (_patientImage == null) {
//       setState(() {
//         _resultMessage = "Please select an image first.";
//       });
//       return;
//     }
//
//     try {
//       var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/upload"));
//       request.fields['userId'] = userId;
//       request.fields['label'] = "example_label"; // Replace with dynamic label if needed
//       request.files.add(
//         http.MultipartFile(
//           'image',
//           _patientImage!.openRead(),
//           await _patientImage!.length(),
//           filename: _patientImage!.path.split('/').last,
//         ),
//       );
//
//       var response = await request.send();
//
//       if (response.statusCode == 200) {
//         var responseBody = await response.stream.bytesToString();
//         var decodedResponse = jsonDecode(responseBody);
//         setState(() {
//           _resultMessage = decodedResponse["message"] ?? "Image uploaded successfully.";
//         });
//       } else {
//         setState(() {
//           _resultMessage = "Failed to upload image. (${response.statusCode})";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _resultMessage = "Error occurred: $e";
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }
//
//
//


// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AddRelativeScreen extends StatefulWidget {
//   @override
//   _AddRelativeScreenState createState() => _AddRelativeScreenState();
// }
//
// class _AddRelativeScreenState extends State<AddRelativeScreen> {
//   List<RelativeWidget> relatives = [RelativeWidget(key: UniqueKey())];
//   final ImagePicker _picker=ImagePicker();
//     Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//
//     if (pickedFile != null) {
//       setState(() {
//         _patientImage = File(pickedFile.path);
//         _resultMessage = "";
//         print('uploded '+_patientImage!.path);
//       });
//     }
//   }
//
//
//     void _showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Choose Image Source"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text("Camera"),
//                 onTap: () {
//                   Navigator.pop(context); // Close the dialog
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text("Gallery"),
//                 onTap: () {
//                   Navigator.pop(context); // Close the dialog
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _addRelative() {
//     setState(() {
//       relatives.add(RelativeWidget(key: UniqueKey()));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Relative'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: relatives.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: relatives[index],
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _addRelative,
//
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('Add More'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class RelativeWidget extends StatefulWidget {
//   RelativeWidget({Key? key}) : super(key: key);
//
//   @override
//   _RelativeWidgetState createState() => _RelativeWidgetState();
// }
//
// class _RelativeWidgetState extends State<RelativeWidget> {
//   String? relationship;
//   Image? uploadedImage;
//
//   void _pickImage() async {
//     // Dummy image picker logic, replace with actual implementation if needed.
//     setState(() {
//       uploadedImage = Image.asset('assets/placeholder.png'); // Replace this with real image picker.
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2.0,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DottedBorder(
//               borderType: BorderType.RRect,
//               radius: Radius.circular(12),
//               dashPattern: [6, 3],
//               strokeWidth: 2,
//               child: InkWell(
//                 onTap: _pickImage,
//                 child: Container(
//                   width: double.infinity,
//                   height: 150,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: uploadedImage != null
//                       ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: uploadedImage,
//                   )
//                       : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
//                       SizedBox(height: 8.0),
//                       Text(
//                         'Upload Image',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Relationship',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   relationship = value;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:io';
import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:alz/screens/HomeScreen.dart';
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


  void _addRelative() {
    setState(() {
      relatives.add(RelativeWidget(key: UniqueKey()));
    });
  }

  Future<void> _uploadAll(String userId) async {
    print("sending ");
    for (var relativeWidget in relatives) {
      if (relativeWidget.state != null) {
        await relativeWidget.state!._upload(userId);
      }

    }
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
  final ImagePicker _picker=ImagePicker();
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
    print("relation "+ relationship!);
    print("image name "+ uploadedImage!.path);

    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/upload"));
      request.fields['userId'] = userId;
      request.fields['label'] = relationship!; // Replace with dynamic label if needed
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
                onTap: _pickImage,  // Open dialog on tap
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
            if (resultMessage != null)
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

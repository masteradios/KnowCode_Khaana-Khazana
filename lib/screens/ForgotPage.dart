import 'package:alz/screens/DeepFace.dart';
import 'package:flutter/material.dart';

import 'Yolo.dart';

class ForgotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.deepPurple, // Tab bar background color
            child: TabBar(
              indicatorColor: Colors.white, // Tab indicator color
              labelColor: Colors.white, // Selected tab label color
              unselectedLabelColor: Colors.white70, // Unselected tab label color
              tabs: [
                Tab(text: 'Object Detection'),
                Tab(text: 'Face Detection'),
              ],
            ),
          ),
          // Tab bar views
          Expanded(
            child: TabBarView(
              children: [
                ImageRecognizer(), // Page for Object Detection
                FaceCheckPage()       // Page for Face Detection
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy pages for ObjectDetection and Deepface
class ObjectDetection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Object Detection Page',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class Deepface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Face Detection Page',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

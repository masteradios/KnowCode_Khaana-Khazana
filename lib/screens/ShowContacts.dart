import 'dart:convert';
import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import '../helper/services/getImages.dart';
import '../models/imageModel.dart';

class ImageListPage extends StatelessWidget {
  ImageListPage();

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).userModel!;
    return FutureBuilder<List<ImageData>>(
      future: fetchImages(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No images found.'));
        } else {
          final images = snapshot.data!;
          return Expanded(
            child: FlutterCarousel(
              options: FlutterCarouselOptions(
                autoPlay: false,
                autoPlayInterval: const Duration(seconds: 2),
                padEnds: false, // Removes the padding at the ends
                viewportFraction: 1.0, // Ensures full image width
              ),
              items: images.map((image) {
                final bytes = base64Decode(image.base64Image);
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(8),topLeft:  Radius.circular(8)),
                            child: Container(
                              height: 300,
                              width: double.infinity,
                              child: Image.memory(
                                bytes,
                                fit: BoxFit.fitWidth,
                              ),
                            ),

                          ),
                          Text(image.name,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          SizedBox(height: 5,)
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

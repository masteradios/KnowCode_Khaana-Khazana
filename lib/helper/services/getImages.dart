import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:alz/pages.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../models/imageModel.dart';

Future<List<ImageData>> fetchImages(String userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/get_images?userId=$userId'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['images'];
    return data.map((item) => ImageData.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load images');
  }
}



// Function to fetch the image URLs and names dynamically
Future<void> fetchDynamicImageData(String userId,BuildContext context) async {
  try {
    final List<ImageData> imageDataList = await fetchImages(userId);
    Provider.of<ImagesProvider>(context,listen:false).setImages(imageDataList);
    List<String> imageUrls = imageDataList.map((imageData) => imageData.base64Image).toList();
    List<String> relation = imageDataList.map((imageData) => imageData.name).toList();

    // Now, imageUrls and relation are dynamically populated

    print('Relations: $relation');

    // Use these lists wherever needed
  } catch (e) {
    print('Error fetching image data: $e');
  }
}


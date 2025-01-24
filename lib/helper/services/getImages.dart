import 'dart:convert';
import 'package:alz/pages.dart';
import 'package:http/http.dart' as http;
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

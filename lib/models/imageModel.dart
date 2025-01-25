import 'package:flutter/cupertino.dart';

class ImageData {
  final String name;
  final String base64Image;

  ImageData({required this.name, required this.base64Image});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      name: json['name'],
      base64Image: json['image'],
    );
  }
}


class ImagesProvider extends ChangeNotifier{

  List<ImageData> _imagesData=[];
  List<ImageData> get imagesData=>_imagesData;

  void setImages(List<ImageData> images){
    _imagesData=images;
    notifyListeners();
  }


}

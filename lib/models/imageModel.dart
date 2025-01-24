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

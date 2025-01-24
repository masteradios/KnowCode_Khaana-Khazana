class TileModel{

  String imageAssetPath;
  bool isSelected;

  TileModel({required this.imageAssetPath, required this.isSelected});

  void setImageAssetPath(String getImageAssetPath){
    imageAssetPath = getImageAssetPath;
  }

  String getImageAssetPath(){
    return imageAssetPath;
  }

  void setterIsSelected(bool getIsSelected){
    isSelected = getIsSelected;
  }

  bool getterIsSelected(){
    return isSelected;
  }
}
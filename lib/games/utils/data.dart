import './tileModel.dart';

// Global variables
String selectedTile = "";
int selectedIndex = 0;
bool selected = true;
int points = 0;

// Lists
List<TileModel> myPairs = [];
List<bool> clicked = [];

// Helper function to create a TileModel
TileModel createTile(String imagePath, {bool isSelected = false}) {
  return TileModel(imageAssetPath: imagePath, isSelected: isSelected);
}

// Get the `clicked` list
List<bool> getClicked() {
  List<bool> yoClicked = [];
  List<TileModel> myairs = getPairs();

  for (int i = 0; i < myairs.length; i++) {
    yoClicked.add(false);
  }

  return yoClicked;
}

// Get pairs of tiles
List<TileModel> getPairs() {
  List<TileModel> pairs = [];

  // Add animal image pairs
  pairs.addAll([
    createTile("assets/fox.png"),
    createTile("assets/fox.png"),
    createTile("assets/hippo.png"),
    createTile("assets/hippo.png"),
    createTile("assets/horse.png"),
    createTile("assets/horse.png"),
    createTile("assets/monkey.png"),
    createTile("assets/monkey.png"),
    createTile("assets/panda.png"),
    createTile("assets/panda.png"),
    createTile("assets/parrot.png"),
    createTile("assets/parrot.png"),
    createTile("assets/rabbit.png"),
    createTile("assets/rabbit.png"),
    createTile("assets/zoo.png"),
    createTile("assets/zoo.png"),
  ]);

  return pairs;
}

// Get question pairs
List<TileModel> getQuestionPairs() {
  List<TileModel> pairs = [];

  // Add question mark image pairs
  for (int i = 0; i < 8; i++) {
    pairs.add(createTile("assets/question.png"));
    pairs.add(createTile("assets/question.png"));
  }

  return pairs;
}

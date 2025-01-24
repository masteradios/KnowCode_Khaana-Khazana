import 'package:flutter/material.dart';

class ItemModel {
  final String? name;
  final String? img;
  final String? value;
  bool accepting;
  ItemModel({this.name, this.value, this.img, this.accepting = false});
}


class FirstGameScreen extends StatefulWidget {
  static const routeName = '/firstGame';
  const FirstGameScreen({Key? key}) : super(key: key);

  @override
  _FirstGameScreenState createState() => _FirstGameScreenState();
}

class _FirstGameScreenState extends State<FirstGameScreen> {
  late List<ItemModel> items = [];
  late List<ItemModel> items2;
  late int score;
  late bool gameOver;
  bool isLoading = false;


  initGame() {
    gameOver = false;
    score = 0;

    List<String> imageUrls = [
      'https://tse2.mm.bing.net/th?id=OIP.pfDlSfWbNJTqAqHlrYsNTwHaJ4&pid=Api',
      'https://tse2.mm.bing.net/th?id=OIP.fb0WC-tbOMHFKSYKrzD-awHaEo&pid=Api',
      'https://tse3.mm.bing.net/th?id=OIP.-ziROjSkHwwowC2LKiX1jwHaJQ&pid=Api',
      'https://tse4.mm.bing.net/th?id=OIP.C8bPx7F_TH8RkI248aB4egHaKg&pid=Api',
    ];

// List of names corresponding to the images
    List<String> names = [
      'Famous Celebrities',
      'Celebrity Images',
      'Secrets of Stars',
      'Best Makeup Looks'
    ];

    // Populate the items list using a for loop
    for (int i = 0; i < imageUrls.length; i++) {
      items.add(ItemModel(value: names[i], name: names[i], img: imageUrls[i]));
    }
    items2 = List<ItemModel>.from(items);

    items.shuffle();
    items2.shuffle();
  }


  @override
  void initState() {
    super.initState();
    initGame();
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) gameOver = true;
    return Scaffold(
      body: Container(
        height: 1000,
        color: Colors.blue,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[100]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Score : ',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          TextSpan(
                            text: '$score',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                if (!gameOver)
                  Row(
                    children: [
                      Spacer(),
                      Column(
                        children: items.map((item) {
                          return Container(
                            margin: EdgeInsets.all(8),
                            child: Draggable<ItemModel>(
                              data: item,
                              childWhenDragging: Container(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  item.img!,
                                ),
                                // child: ClipOval(
                                //   child: Image.network(
                                //     item.img!,
                                //     width: 100,
                                //     height: 100,
                                //     fit: BoxFit.fill,
                                //   ),
                                // ),
                              ),
                              feedback: Container(
                                width: 100,
                                height: 100,
                                child: ClipOval(
                                  child: Image.network(
                                    item.img!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 100,
                                height: 100,
                                child: ClipOval(
                                  child: Image.network(
                                    item.img!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Spacer(flex: 2),
                      Column(
                        children: items2.map((item) {
                          return DragTarget<ItemModel>(
                            onAccept: (receivedItem) {
                              if (item.value == receivedItem.value) {
                                setState(() {
                                  items.remove(receivedItem);
                                  items2.remove(item);
                                });
                                score += 10;
                                item.accepting = false;
                              } else {
                                setState(() {
                                  score -= 5;
                                  item.accepting = false;
                                });
                              }
                            },
                            onWillAccept: (receivedItem) {
                              setState(() {
                                item.accepting = true;
                              });
                              return true;
                            },
                            onLeave: (receivedItem) {
                              setState(() {
                                item.accepting = false;
                              });
                            },
                            builder: (context, acceptedItems, rejectedItems) =>
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: item.accepting
                                          ? Colors.blue[900]
                                          : Colors.blue[400],
                                    ),
                                    alignment: Alignment.center,
                                    height:
                                        MediaQuery.of(context).size.width / 6.5,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    margin: const EdgeInsets.all(12),
                                    child: Text(
                                      item.name!,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )),
                          );
                        }).toList(),
                      ),
                      Spacer(),
                    ],
                  ),
                if (gameOver)
                  Center(
                    child: Column(),
                  ),
                SizedBox(
                  height: 50,
                ),
                if (gameOver)
                  Container(
                    height: MediaQuery.of(context).size.width / 10,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8)),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            initGame();
                          });
                        },
                        child: Text(
                          'New Game',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Functions:

  Text result() {
    if (score == 140) {
      return Text(
        'Awesome!!',
        style: TextStyle(color: Colors.white, fontSize: 30),
      );
    } else {
      return Text(
        'Play again! Score better',
        style: TextStyle(color: Colors.white, fontSize: 30),
      );
    }
  }
}

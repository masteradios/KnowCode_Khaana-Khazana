import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../games/firstGame.dart';
import '../games/secondGame.dart';
import '../games/thirdGame.dart';
import 'PersonalInfo.dart';




class EssentialScreen extends StatefulWidget {
  static const routeName = '/essential';
  const EssentialScreen({super.key});

  @override
  State<EssentialScreen> createState() => _EssentialScreenState();
}

class _EssentialScreenState extends State<EssentialScreen> {





  bool isLoading = false;

  int _selectedEvent = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
  UserModel user=   Provider.of<UserProvider>(context).userModel!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[200],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Hi, ${user.name}!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('23 Jan,2021',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                    //notification
                    Tooltip(
                      message: 'Share your location',
                      child: TextButton(
                        onPressed: () {
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.deepPurple[600],
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Iconsax.gps,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 100,
                  margin: EdgeInsets.all(10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context){
                                return FirstGameScreen();
                          }));
                        },
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[600],
                              borderRadius: BorderRadius.circular(12)),
                          margin: EdgeInsets.only(right: 5),
                          child: Center(
                              child: Text(
                                'Connect',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context){return LetterClickGameScreen();}));
                        },
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[600],
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(
                                'Pronounce It',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_){
                            return QuizPage();
                          }));
                        },
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[600],
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(
                                'Know Yourself',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),

            //search bar

            //How do you feel
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'How do you feel?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  //4 different faces

                ],
              ),
            ),

            SizedBox(
              height: 24,
            ),
            Personal_Info(),
            buildUserEvents(size),

          ],
        ),
      ),
    );
  }

  Container buildUserEvents(Size size) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: size.width / 1.8,
              padding: EdgeInsets.all(8),
              child: MaterialButton(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple.shade700),
                ),
                color: _selectedEvent == 0
                    ? Colors.deepPurple.shade700
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedEvent = 0;
                  });
                  _navigateToPage(0); // Navigate to Gallery screen
                },
                child: Text(
                  "Relatives",
                  style: TextStyle(
                    color: _selectedEvent == 0
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: size.width / 1.8,
              padding: EdgeInsets.all(8),
              child: MaterialButton(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple.shade700),
                ),
                color: _selectedEvent == 1
                    ? Colors.deepPurple.shade700
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedEvent = 1;
                  });
                  _navigateToPage(1); // Navigate to Contact page
                },
                child: Text(
                  "Contact",
                  style: TextStyle(
                    color: _selectedEvent == 1
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: 30,
              padding: EdgeInsets.all(8),
              child: MaterialButton(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple.shade700),
                ),
                color: _selectedEvent == 2
                    ? Colors.deepPurple.shade700
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedEvent = 2;
                  });
                  _navigateToPage(2); // Navigate to Image Recognizer page
                },
                child: Text(
                  "Recognize",
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedEvent == 2
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    // switch (index) {
    //   case 1:
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => ContactList()),
    //     );
    //     break;
    //   case 2:
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => ImageRecognizer()),
    //     );
    //     break;
    // }
  }
}

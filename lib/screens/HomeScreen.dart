import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:alz/screens/EssentialScreens.dart';
import 'package:alz/screens/signUpScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:workmanager/workmanager.dart';

import '../ShakeDetector.dart';
import '../games/firstGame.dart';
import '../games/secondGame.dart';
import '../games/thirdGame.dart';
import '../helper/diseases.dart';
import '../helper/helperFunctions.dart';
import '../pages.dart';
import 'FloatingChatBot.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //final ReminderService _reminderService = ReminderService();
  bool isLoading = false;
  double homeLat = 0;
  double homeLong = 0;
  bool _isNotificationSent = false;
  bool _isMounted = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isChatVisible = false;
  Offset _offset = const Offset(50, 400);
  double _chatBottomPosition = 130;

  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Track listening state
  String _spokenText = ''; // Hold recognized text
  final ScrollController _scrollController = ScrollController();


  Future<String> getBotResponse(String query) async {
    final url = Uri.parse('https://71b1-2409-40c0-7e-776f-d435-b81c-4f9e-7cf0.ngrok-free.app/chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': query}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return _getIntent(responseData['text']);
    } else {
      return 'Error: ${response.statusCode}';
    }
  }

  String _getIntent(String userMessage) {
    if (userMessage.toLowerCase().contains('1')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FirstGameScreen()));
      return 'Routing you to the game page 1...';
    } else if (userMessage.toLowerCase().contains('2')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LetterClickGameScreen()));
      return 'Routing you to the game page 2...';
    } else if (userMessage.toLowerCase().contains('3')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizPage()));
      return 'Routing you to the game page 3...';
    } else {
      return 'Sorry, this feature is not in the app.';
    }
  }

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'user': message});
      });

      final botResponse = await getBotResponse(message);

      setState(() {
        _messages.add({'bot': botResponse});
      });

      _controller.clear();
      _scrollToBottom();
    }
  }


  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });
          if (!_speech.isListening) {
            _sendMessage(_spokenText); // Send the recognized text
          }
        },
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    _scrollToBottom();
  }

  void _scrollToBottom(){
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    scheduleNotifications();
    Workmanager().registerPeriodicTask('appReminder', 'showAppReminder',frequency: Duration(minutes: 30));
    ShakeDetector shakeDetector=ShakeDetector.autoStart(onPhoneShake: (){
      showNotification("SOS Sent !!", "Your contacts have been informed!");

    });
  }
  void scheduleNotifications() {
    int? severity = dementiaConditions['sda'];
    dementiaConditions.forEach((condition, severity) {
      String channelKey =
      severity >= 8 ? 'high_frequency' : 'low_frequency'; // Frequency logic

      // Notification Content
      String message = severity >= 8
          ? "Reminder: Use SOS and Face Recognition for emergencies."
          : "Stay safe! Use SOS and YOLO when needed.";

      int frequencyMinutes = severity >= 8 ? 10 : 30;

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: severity,
          channelKey: channelKey,
          title: "Stay Prepared: Important Features for $condition",
          body: message,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationInterval(
          interval: Duration(minutes: frequencyMinutes),// Convert minutes to seconds
          timeZone: DateTime.now().timeZoneName,
          preciseAlarm: true,
        ),
      );
    });
  }


  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();

    // Navigate to the login page after signing out
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
      return SignUpScreen();
    }), (route) => false);
  }


  int selectedIndex = 0;
  Widget _buildChatWindow() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // Chat Header
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFF5ECFF),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Chatbot',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isChatVisible = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Chat Messages
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.containsKey('user');
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isUser ? Color(0xFFF5ECFF) : Color(0xFFE197FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isUser ? message['user']! : message['bot']!,
                        style: TextStyle(color: isUser ? Colors.black : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input Field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about app features...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _sendMessage(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    color: _isListening ? Colors.red : Colors.black,
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom-100;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        setState(() {
          _isChatVisible = !_isChatVisible;
        });
      },child: Icon(Iconsax.message),),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(
                Iconsax.logout,
                color: Colors.white,
              ))
        ],
        title: Text(
          'YaadonKiBaarat',
          style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.w900)
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          elevation: 5,
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) =>
            states.contains(MaterialState.selected)
                ? TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          child: NavigationBar(
            animationDuration: Duration(milliseconds: 50),
            selectedIndex: selectedIndex,
            indicatorColor: Colors.white60,
            backgroundColor: Colors.deepPurple,
            onDestinationSelected: (newIndex) {
              setState(() {
                selectedIndex = newIndex;
              });
            },
            destinations: [
              NavigationItem(text: 'Home', icon: (Iconsax.home)),
              NavigationItem(text: 'To-do', icon: (Iconsax.note)),
              NavigationItem(text: 'My Doctor', icon: (Iconsax.health)),
              NavigationItem(text: 'Forgot ?', icon: (Iconsax.message_question)),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          pages[selectedIndex],
          // Floating Action Button

          if (_isChatVisible)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: bottomInset > 0 ? bottomInset : _chatBottomPosition,
              right: 20,
              child: _buildChatWindow(),
            ),
        ],
      ),

      //body: pages[selectedIndex],
      extendBody: (selectedIndex == 3 || selectedIndex == 1) ? false : true,
    );
  }
}

class NavigationItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const NavigationItem({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: Icon(
        icon,
        color: Colors.white,
        size: 25,
      ),
      label: text,
    );
  }
}

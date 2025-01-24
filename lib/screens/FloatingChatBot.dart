import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../games/firstGame.dart';
import '../games/secondGame.dart';
import '../games/thirdGame.dart';


class FloatingChat extends StatefulWidget {
  final Widget child;

  const FloatingChat({Key? key, required this.child}) : super(key: key);


  @override
  _FloatingChatState createState() => _FloatingChatState();
}

class _FloatingChatState extends State<FloatingChat> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isChatVisible = false;
  Offset _offset = const Offset(50, 400);
  double _chatBottomPosition = 20;

  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Track listening state
  String _spokenText = ''; // Hold recognized text
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }


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
  Widget build(BuildContext context) {

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        widget.child,
        // Floating Action Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isChatVisible = !_isChatVisible;
              });
            },
            child: const Icon(Icons.chat),
          ),
        ),

        if (_isChatVisible)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: bottomInset > 0 ? bottomInset : _chatBottomPosition,
            right: 20,
            child: _buildChatWindow(),
          ),
      ],
    );
  }

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
}

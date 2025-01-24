// import 'package:flutter/material.dart';
//
// class QuizPage extends StatefulWidget {
//   static const routeName = '/thirdGame';
//   @override
//   _QuizPageState createState() => _QuizPageState();
// }
//
// class _QuizPageState extends State<QuizPage> {
//   int _currentQuestion = 0;
//   int _score = 0;
//
//   List<Map<String, dynamic>> _questions = [
//     {
//       'question': 'What is the your father\'s name?',
//       'answers': ['Roji', 'Hemant', 'Raju', 'Shyam'],
//       'correctAnswer': 1,
//       'score': 10,
//     },
//     {
//       'question': 'What is the your mother\'s name?',
//       'answers': ['Sharda', 'Shamila', 'Suman', 'Vasu'],
//       'correctAnswer': 1,
//       'score': 20,
//     },
//     {
//       'question': 'Where do you live?',
//       'answers': ['Nagpur', 'Mulund', 'Kurla', 'Chembur'],
//       'correctAnswer': 1,
//       'score': 20,
//     },
//     {
//       'question': 'What is your age?',
//       'answers': ['20', '21', '25', '31'],
//       'correctAnswer': 2,
//       'score': 20,
//     },
//     {
//       'question': 'Where do you work?',
//       'answers': ['Nagpur', 'Mulund', 'Kurla', 'Chembur'],
//       'correctAnswer': 2,
//       'score': 20,
//     },
//     {
//       'question': 'What is your occupation?',
//       'answers': ['Floor Washer', 'Peon', 'Engineer', 'Politician'],
//       'correctAnswer': 3,
//       'score': 20,
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quiz'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Text(
//               _questions[_currentQuestion]['question'],
//               style: TextStyle(fontSize: 20.0),
//             ),
//             SizedBox(height: 10.0),
//             Column(
//               children: List.generate(
//                 _questions[_currentQuestion]['answers'].length,
//                 (index) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(vertical: 8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.0),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: ListTile(
//                         selectedColor: Colors.green,
//                         title: Text(
//                             '${index + 1}. ${_questions[_currentQuestion]['answers'][index]}'),
//                         trailing: _questions[_currentQuestion]
//                                     .containsKey('isAnswered') &&
//                                 _questions[_currentQuestion]['isAnswered'] &&
//                                 _questions[_currentQuestion]['correctAnswer'] ==
//                                     index
//                             ? Icon(Icons.check, color: Colors.green)
//                             : null,
//                         onTap: () => _checkAnswer(index),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Text('Score: $_score'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // _checkAnswer(int answerIndex) {
//   //   setState(() {
//   //     if (_questions[_currentQuestion]['correctAnswer'] == answerIndex) {
//   //       _score += _questions[_currentQuestion]['score'] as int;
//   //     } else {
//   //       // Show correct answer
//   //       _questions[_currentQuestion]['isAnswered'] = true;
//   //     }
//   //
//   //     _currentQuestion++;
//   //
//   //     if (_currentQuestion >= _questions.length) {
//   //       // Show results page
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => ResultsPage(score: _score)),
//   //       );
//   //     }
//   //   });
//   // }
//
//   void _checkAnswer(int answerIndex) {
//     setState(() {
//       if (_questions[_currentQuestion]['correctAnswer'] == answerIndex) {
//         _score += _questions[_currentQuestion]['score'] as int;
//       }
//       if (_currentQuestion + 1 < _questions.length) {
//         _currentQuestion++;
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => ResultsPage(score: _score)),
//         );
//       }
//     });
//   }
//
// }
// class ResultsPage extends StatelessWidget {
//   final int score;
//
//   ResultsPage({required this.score});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Results')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Your score: $score', style: TextStyle(fontSize: 24)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.popUntil(context, ModalRoute.withName('/'));
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('Restart Quiz'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//



import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  static const routeName = '/thirdGame';

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _isAnswered = false;

  List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is your father\'s name?',
      'answers': ['Roji', 'Hemant', 'Raju', 'Shyam'],
      'correctAnswer': 1,
      'score': 10,
    },
    {
      'question': 'What is your mother\'s name?',
      'answers': ['Sharda', 'Shamila', 'Suman', 'Vasu'],
      'correctAnswer': 1,
      'score': 20,
    },
    {
      'question': 'Where do you live?',
      'answers': ['Nagpur', 'Mulund', 'Kurla', 'Chembur'],
      'correctAnswer': 1,
      'score': 20,
    },
  ];

  void _submitAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an answer before submitting!')),
      );
      return;
    }

    setState(() {
      _isAnswered = true;
      if (_selectedAnswer == _questions[_currentQuestion]['correctAnswer']) {
        _score += _questions[_currentQuestion]['score'] as int;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correct!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    });
  }

  // void _nextQuestion() {
  //
  //   setState(() {
  //
  //       _currentQuestion++;
  //
  //
  //     _selectedAnswer = null;
  //     _isAnswered = false;
  //   });
  //
  //   if (_currentQuestion >= _questions.length) {
  //     // Navigate to results page
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => ResultsPage(score: _score)),
  //     );
  //   }
  // }

  void _nextQuestion() {
    if (_currentQuestion >= _questions.length - 1) {
      // Navigate to results page if it's the last question
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultsPage(score: _score)),
      );
    } else {
      // Move to the next question
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _questions[_currentQuestion]['question'],
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Column(
              children: List.generate(
                _questions[_currentQuestion]['answers'].length,
                    (index) {
                  final isCorrect =
                      index == _questions[_currentQuestion]['correctAnswer'];
                  final isSelected = index == _selectedAnswer;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (!_isAnswered) {
                          setState(() {
                            _selectedAnswer = index;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: _isAnswered
                                ? (isCorrect
                                ? Colors.green
                                : (isSelected ? Colors.red : Colors.grey))
                                : (isSelected
                                ? Colors.blue
                                : Colors.grey), // Highlight selected
                            width: 2.0,
                          ),
                          color: _isAnswered
                              ? (isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : (isSelected
                              ? Colors.red.withOpacity(0.2)
                              : Colors.transparent))
                              : Colors.transparent,
                        ),
                        child: ListTile(
                          title: Text(
                            '${index + 1}. ${_questions[_currentQuestion]['answers'][index]}',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isAnswered ? null : _submitAnswer,
                  child: Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: _isAnswered ? _nextQuestion : null,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Score: $_score',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final int score;

  ResultsPage({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your score: $score', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

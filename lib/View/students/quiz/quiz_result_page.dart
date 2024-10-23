import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Homescreen.dart';

class QuizPage extends StatefulWidget {
  final String assignedDate;
  final String Userid;
  final String location;
  final String trade;
  final String email;
  final String image;
  QuizPage(
      {required this.assignedDate,
      required this.Userid,
      required this.location,
      required this.trade,
      required this.email,
      required this.image});
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _selectedIndex = -1;
  int _correctAnswer = -1;
  bool _isAnswered =
      false; // Track if the user has answered the current question

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('quiz_questions')
        .where("dateAdded", isEqualTo: widget.assignedDate)
        .get();
    setState(() {
      _questions = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void _submitAnswer(int selectedOption) {
    if (!_isAnswered) {
      setState(() {
        _selectedIndex = selectedOption;
        _correctAnswer = _questions[_currentQuestionIndex]['correctOption'];
        _isAnswered = true; // Mark the question as answered

        // Check if the selected option is correct, and update the score
        if (_selectedIndex == _correctAnswer) {
          _score++;
        }
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedIndex = -1; // Reset the selected option for the next question
        _isAnswered = false; // Reset the answered state for the next question
      });
    } else {
      // When all questions are answered, show the final score
      _showFinalScoreDialog();
    }
  }

  void _showFinalScoreDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Completed',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        content: Text(
          'Your final score is: $_score',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection("Submitanswer").add({
                "Assigneddate": widget.assignedDate,
                "scrore": _score * 4,
                "userid": widget.Userid,
                "location": widget.location,
                "trade": widget.trade,
                "image": widget.image,
                "email": widget.email
              });
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return StudentHome();
                },
              ));
              // Exit the quiz page
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final options = List<String>.from(question['options']);
    final correctOption = question['correctOption'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              " Q: ${_currentQuestionIndex + 1}/${_questions.length}",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          )
        ],
        title: Text(
          "APTITUDE",
          style: GoogleFonts.abhayaLibre(
              color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 10, // Limits the text to a specific number of lines
              overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
              softWrap: true, // Ensures the text wraps properly
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(options.length, (optionIndex) {
                return GestureDetector(
                  onTap: _isAnswered
                      ? null
                      : () => _submitAnswer(
                          optionIndex), // Disable tap after answer
                  child: Container(
                    width: 1.sw,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIndex == optionIndex
                          ? (_selectedIndex == correctOption
                              ? Colors.green
                              : Colors.red)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      options[optionIndex],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: _isAnswered ? _nextQuestion : null,
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue),
                      child: Center(
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? "SUBMIT"
                              : "NEXT",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

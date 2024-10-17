import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {


final String assignedDate;
  QuizPage({required this.assignedDate});
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _selectedIndex = -1;
  int _correctAnswer = -1;
  bool _isAnswered = false; // Track if the user has answered the current question

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('quiz_questions').where("dateAdded",isEqualTo:widget.assignedDate).get();
    setState(() {
      _questions = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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
        title: Text('Quiz Completed'),
        content: Text('Your final score is: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Exit the quiz page
            },
            child: Text('OK'),
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
        title: Text('Quiz - Question ${_currentQuestionIndex + 1}/${_questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(options.length, (optionIndex) {
                return GestureDetector(
                  onTap: _isAnswered ? null : () => _submitAnswer(optionIndex), // Disable tap after answer
                  child: Container(width: 200,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIndex == optionIndex
                          ? (_selectedIndex == correctOption ? Colors.green : Colors.red)
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAnswered ? _nextQuestion : null, // Only move to next if answered
              child: Text(_currentQuestionIndex == _questions.length - 1
                  ? 'Submit Quiz'
                  : 'Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}

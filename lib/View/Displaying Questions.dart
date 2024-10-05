// lib/View/QuizScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/Questions.dart';
import '../ViewModel/viewmodel.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        actions: [
          Consumer<QuizViewModel>(
            builder: (context, quizViewModel, child) {
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  quizViewModel.resetQuiz();
                  setState(() {
                    _selectedOption = null;
                  });
                },
              );
            },
          )
        ],
      ),
      body: Consumer<QuizViewModel>(
        builder: (context, quizViewModel, child) {
          if (quizViewModel.questions.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (quizViewModel.isQuizCompleted) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quiz Completed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your Score: ${quizViewModel.score} / ${quizViewModel.questions.length}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      quizViewModel.resetQuiz();
                      setState(() {
                        _selectedOption = null;
                      });
                    },
                    child: Text('Restart Quiz'),
                  ),
                ],
              ),
            );
          }

          Question currentQuestion =
              quizViewModel.questions[quizViewModel.currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Question ${quizViewModel.currentQuestionIndex + 1} of ${quizViewModel.questions.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  currentQuestion.questionText,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                ...List.generate(currentQuestion.options.length, (index) {
                  return RadioListTile<int>(
                    title: Text(currentQuestion.options[index]),
                    value: index,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  );
                }),
                Spacer(),
                GestureDetector(
                  onTap: _selectedOption == null
                      ? null
                      : () {
                          bool isCorrect =
                              _selectedOption == currentQuestion.correctOption;

                          if (isCorrect) {
                            // Optionally, show a correct answer indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Correct!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Optionally, show a wrong answer indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Wrong! Correct answer is "${currentQuestion.options[currentQuestion.correctOption]}"'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          // Update the ViewModel
                          quizViewModel.selectOption(_selectedOption!);

                          // Move to next question
                          quizViewModel.nextQuestion();

                          // Reset selected option
                          setState(() {
                            _selectedOption = null;
                          });
                        },
                  child: Container(
                    height: 50,
                    width: 200,
                    child: Center(
                      child: Text(quizViewModel.currentQuestionIndex <
                              quizViewModel.questions.length - 1
                          ? 'Next'
                          : 'Submit'),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedOption == null
                      ? null
                      : () {
                          bool isCorrect =
                              _selectedOption == currentQuestion.correctOption;

                          if (isCorrect) {
                            // Optionally, show a correct answer indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Correct!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Optionally, show a wrong answer indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Wrong! Correct answer is "${currentQuestion.options[currentQuestion.correctOption]}"'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          // Update the ViewModel
                          quizViewModel.selectOption(_selectedOption!);

                          // Move to next question
                          quizViewModel.nextQuestion();

                          // Reset selected option
                          setState(() {
                            _selectedOption = null;
                          });
                        },
                  child: Text(quizViewModel.currentQuestionIndex <
                          quizViewModel.questions.length - 1
                      ? 'Next'
                      : 'Submit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

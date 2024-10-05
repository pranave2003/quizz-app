// lib/View/AddQuestionPage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../Model/Questions.dart';
import '../../ViewModel/viewmodel.dart';
import '../Displaying Questions.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctOptionIndex = 0;

  bool _isButtonEnabled() {
    // Disable the button if any of the fields are empty
    return _questionController.text.isNotEmpty &&
        _optionControllers.every((controller) => controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final quizViewModel = Provider.of<QuizViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Add Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Enter Question'),
                onChanged: (_) =>
                    setState(() {}), // Rebuild to check for button enabling
              ),
              SizedBox(height: 16),
              Text(
                'Enter Options:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...List.generate(4, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration:
                            InputDecoration(labelText: 'Option ${index + 1}'),
                        onChanged: (_) => setState(
                            () {}), // Rebuild to check for button enabling
                      ),
                    ),
                    Radio<int>(
                      value: index,
                      groupValue: _correctOptionIndex,
                      onChanged: (value) {
                        setState(() {
                          _correctOptionIndex = value!;
                        });
                      },
                    ),
                  ],
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonEnabled()
                    ? () async {
                        String questionText = _questionController.text;
                        List<String> options = _optionControllers
                            .map((controller) => controller.text)
                            .toList();

                        if (questionText.isNotEmpty &&
                            options.every((option) => option.isNotEmpty)) {
                          // Get current date
                          String date =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());

                          // Check if questions for today have already reached 25
                          int count =
                              await quizViewModel.questionCountForDate(date);
                          if (count < 25) {
                            Question newQuestion = Question(
                              questionText: questionText,
                              options: options,
                              correctOption: _correctOptionIndex,
                              date: date, // Adding date to the question
                            );

                            // Call ViewModel to add question to Firestore
                            await quizViewModel.addQuestion(newQuestion);

                            // Clear fields after adding
                            _questionController.clear();
                            _optionControllers
                                .forEach((controller) => controller.clear());
                            setState(() {
                              _correctOptionIndex = 0;
                            });

                            // Show a success snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Question added successfully!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Only 25 questions allowed for today!'),
                              ),
                            );
                          }
                        }
                      }
                    : null, // Disable the button if the fields are empty
                child: Text('Add Question'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen()),
                  );
                },
                child: Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

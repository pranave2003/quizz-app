import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/Questions.dart';
import '../ViewModel/viewmodel.dart';
import 'Displaying Questions.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctOptionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Enter Question'),
            ),
            ...List.generate(4, (index) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _optionControllers[index],
                      decoration:
                          InputDecoration(labelText: 'Option ${index + 1}'),
                    ),
                  ),
                  Radio(
                    value: index,
                    groupValue: _correctOptionIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value as int;
                      });
                    },
                  ),
                ],
              );
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String questionText = _questionController.text;
                List<String> options = _optionControllers
                    .map((controller) => controller.text)
                    .toList();

                if (questionText.isNotEmpty &&
                    options.every((option) => option.isNotEmpty)) {
                  Question newQuestion = Question(
                    questionText: questionText,
                    options: options,
                    correctOption: _correctOptionIndex,
                  );

                  // Call ViewModel to add question to Firestore
                  Provider.of<QuizViewModel>(context, listen: false)
                      .addQuestion(newQuestion);

                  // Clear fields after adding
                  _questionController.clear();
                  _optionControllers
                      .forEach((controller) => controller.clear());
                  setState(() {
                    _correctOptionIndex = 0;
                  });
                }
              },
              child: Text('Add Question'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizPage()),
                );
              },
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

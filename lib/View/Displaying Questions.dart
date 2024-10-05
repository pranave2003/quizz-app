import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ViewModel/viewmodel.dart';


class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    // Fetch questions when the widget is initialized
    Provider.of<QuizViewModel>(context, listen: false).fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final quizViewModel = Provider.of<QuizViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                  'Correct: ${quizViewModel.correctCount} | Incorrect: ${quizViewModel.incorrectCount}'),
            ),
          )
        ],
      ),
      body: quizViewModel.questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: quizViewModel.questions.length,
        itemBuilder: (context, index) {
          var question = quizViewModel.questions[index];
          return Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    question.questionText,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(4, (optionIndex) {
                  bool isAttempted =
                  quizViewModel.attemptedQuestions.contains(index);
                  Color answerColor = isAttempted
                      ? (optionIndex == question.correctOption
                      ? Colors.green
                      : Colors.red)
                      : Colors.grey[200]!;

                  return ListTile(
                    title: Text(question.options[optionIndex]),
                    tileColor: answerColor,
                    onTap: isAttempted
                        ? null
                        : () {
                      quizViewModel.checkAnswer(
                          optionIndex, question.correctOption, index);
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

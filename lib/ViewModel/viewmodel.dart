import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/Questions.dart';

class QuizViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to store questions fetched from Firestore
  List<Question> questions = [];

  // Score tracking
  int correctCount = 0;
  int incorrectCount = 0;

  // To track which questions have been attempted
  List<int> attemptedQuestions = [];

  // Fetch all questions from Firestore
  Future<void> fetchQuestions() async {
    final snapshot = await _firestore.collection('questions').get();
    questions = snapshot.docs
        .map((doc) => Question.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    notifyListeners(); // Notify listeners that data has changed
  }

  // Add a question to Firestore
  Future<void> addQuestion(Question question) async {
    await _firestore.collection('questions').add(question.toMap());
    notifyListeners();
  }

  // Check if the selected answer is correct
  void checkAnswer(int selectedOption, int correctOption, int questionIndex) {
    if (!attemptedQuestions.contains(questionIndex)) {
      if (selectedOption == correctOption) {
        correctCount++;
      } else {
        incorrectCount++;
      }
      attemptedQuestions.add(questionIndex);
      notifyListeners(); // Notify listeners that score has been updated
    }
  }
}

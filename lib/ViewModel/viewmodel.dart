// lib/ViewModel/quiz_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Model/Questions.dart';

class QuizViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Question> _questions = [];
  List<int> _selectedOptions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isQuizCompleted = false;

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isQuizCompleted => _isQuizCompleted;

  // Fetch questions from Firestore
  Future<void> fetchQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('questions').get();
      _questions = snapshot.docs
          .map((doc) => Question.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      _selectedOptions = List<int>.filled(
          _questions.length, -1); // Initialize with -1 (no selection)
      notifyListeners();
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  // Add a question to Firestore
  Future<void> addQuestion(Question question) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('questions').add(question.toMap());
      // Optionally, fetch the updated list
      await fetchQuestions();
      notifyListeners();
    } catch (e) {
      print('Error adding question: $e');
    }
  }

  // Get the count of questions for a specific date
  Future<int> questionCountForDate(String date) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('questions')
          .where('date', isEqualTo: date)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error counting questions: $e');
      return 0;
    }
  }

  // Select an option for the current question
  void selectOption(int optionIndex) {
    if (_currentQuestionIndex < _questions.length) {
      _selectedOptions[_currentQuestionIndex] = optionIndex;
      notifyListeners();
    }
  }

  // Move to the next question
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      _isQuizCompleted = true;
      calculateScore();
      notifyListeners();
    }
  }

  // Calculate the score based on selected options
  void calculateScore() {
    _score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedOptions[i] == _questions[i].correctOption) {
        _score++;
      }
    }
  }

  // Reset the quiz to initial state
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizCompleted = false;
    _selectedOptions = List<int>.filled(_questions.length, -1);
    notifyListeners();
  }
}

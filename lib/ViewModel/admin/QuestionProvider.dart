import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import Firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _questions = [];

  List<Map<String, dynamic>> get questions => _questions;

  Future<void> loadQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedQuestions = prefs.getString('questions');
    if (savedQuestions != null) {
      _questions = List<Map<String, dynamic>>.from(jsonDecode(savedQuestions));
      notifyListeners();
    }
  }

  Future<void> saveQuestion(String questionText, List<String> options,
      int correctOption, String dateAdded) async {
    _questions.add({
      'question': questionText,
      'options': options,
      'correctOption': correctOption,
      'dateAdded': dateAdded,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('questions', jsonEncode(_questions));
    notifyListeners();
  }

  Future<void> submitQuestionsToFirebase({ String? selecteddata, }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Check if an entry with the same Assigneddate already exists
    QuerySnapshot existingDateSnapshot = await firestore
        .collection("Assigndate")
        .where("Assigneddate", isEqualTo: selecteddata)
        .get();

    if (existingDateSnapshot.docs.isEmpty) {
      // No existing entry found, so add a new one
      await firestore.collection("Assigndate").add({
        "Assigneddate": selecteddata,
        "status": 0,
      });
    } else {
      // If the date already exists, you can update the existing entry's status
      DocumentSnapshot existingDateDoc = existingDateSnapshot.docs.first;
      await firestore
          .collection("Assigndate")
          .doc(existingDateDoc.id)
          .update({
        "status": 0,
      });
    }

    // Add quiz questions to the Firestore
    for (var question in _questions) {
      await firestore.collection('quiz_questions').add(question);
    }

    // Clear SharedPreferences after submission
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('questions');

    _questions.clear(); // Clear the local list
    notifyListeners();
  }


  // Method to delete a question
  void deleteQuestion(int index) {
    _questions.removeAt(index);
    notifyListeners();
  }

  // Method to update a question
  void updateQuestion(int index, Map<String, dynamic> updatedQuestion) {
    _questions[index] = updatedQuestion;
    notifyListeners();
  }
}

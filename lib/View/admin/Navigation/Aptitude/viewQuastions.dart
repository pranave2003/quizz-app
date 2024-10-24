import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizQuestionsPage extends StatefulWidget {
  const QuizQuestionsPage({Key? key, required this.date}) : super(key: key);
  final String date;

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch questions from Firestore
  Future<List<Map<String, dynamic>>> fetchQuizQuestions() async {
    QuerySnapshot snapshot = await _firestore
        .collection('quiz_questions')
        .where("dateAdded", isEqualTo: widget.date)
        .get();
    List<Map<String, dynamic>> questions = snapshot.docs
        .map((doc) => {
              'id': doc.id, // Store document ID for update/delete
              'question': doc['question'],
              'options': List<String>.from(doc['options']),
              'correctOption': doc['correctOption'],
              'dateAdded': doc['dateAdded'],
            })
        .toList();
    return questions;
  }

  // Function to update a question
  Future<void> updateQuestion(String id, String updatedQuestion,
      List<String> updatedOptions, int updatedCorrectOption) async {
    await _firestore.collection('quiz_questions').doc(id).update({
      'question': updatedQuestion,
      'options': updatedOptions,
      'correctOption': updatedCorrectOption,
    });
  }

  // Function to delete a question
  Future<void> deleteQuestion(String id) async {
    await _firestore.collection('quiz_questions').doc(id).delete();
  }

  // Show an alert dialog for updating a question
  Future<void> showUpdateDialog(BuildContext context, String id,
      String question, List<String> options, int correctOption) async {
    TextEditingController questionController =
        TextEditingController(text: question);
    List<TextEditingController> optionControllers = List.generate(
        options.length, (index) => TextEditingController(text: options[index]));
    TextEditingController correctOptionController =
        TextEditingController(text: correctOption.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade50,
          title: Text('Update Question'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(labelText: 'Question'),
                ),
                ...List.generate(optionControllers.length, (index) {
                  return TextField(
                    controller: optionControllers[index],
                    decoration:
                        InputDecoration(labelText: 'Option ${index + 1}'),
                  );
                }),
                TextField(
                  controller: correctOptionController,
                  decoration:
                      InputDecoration(labelText: 'Correct Option Index'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
            TextButton(
              onPressed: () {
                List<String> updatedOptions = optionControllers
                    .map((controller) => controller.text)
                    .toList();
                int updatedCorrectOption =
                    int.parse(correctOptionController.text);
                updateQuestion(id, questionController.text, updatedOptions,
                    updatedCorrectOption);
                Navigator.pop(context);
                setState(() {}); // Refresh the UI after update
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: Text('Quiz Questions'),
        actions: [
          InkWell(onTap: () {
            FirebaseFirestore.instance.collection("Assigndate").doc("Eh01GrnL0JW6bk28Edlr").update({
              "status":1
            });
          },
              child: Container(
                color: Colors.green,
            height: 50,
            width: 200,
            child: Center(child: Text("Publish")),
          ))
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuizQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No questions found'),
            );
          } else {
            List<Map<String, dynamic>> questions = snapshot.data!;
            return ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                var question = questions[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${index + 1}: ${question['question']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Options:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            question['options'].length,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child:
                                  Text('${i + 1}. ${question['options'][i]}'),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Correct Option: ${question['correctOption'] + 1}',
                          style: TextStyle(color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Assigned Date: ${question['dateAdded']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                showUpdateDialog(
                                  context,
                                  question['id'],
                                  question['question'],
                                  question['options'],
                                  question['correctOption'],
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Show a confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.blue.shade50,
                                      title: Text('Delete'),
                                      content: Text(
                                          'Are you sure you want to delete this Question?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // Close the dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteQuestion(question['id']);
                                            Navigator.pop(
                                                context); // Close the dialog
                                          },
                                          child: Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

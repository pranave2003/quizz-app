import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizQuestionsPage extends StatefulWidget {
  const QuizQuestionsPage({Key? key, required this.date, required this.id})
      : super(key: key);

  final String date;
  final String id;

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int currentStatus = 0; // Track the current status

  @override
  void initState() {
    super.initState();
    fetchCurrentStatus(); // Fetch the initial status when the screen loads
  }

  // Fetch the current status from Firestore
  Future<void> fetchCurrentStatus() async {
    DocumentSnapshot doc =
    await _firestore.collection('Assigndate').doc(widget.id).get();

    if (doc.exists) {
      setState(() {
        currentStatus = doc['status'] ?? 0; // Default to 0 if not found
      });
    }
  }

  // Toggle the status between 0 and 1
  Future<void> toggleStatus() async {
    int newStatus = currentStatus == 0 ? 1 : 0;

    await _firestore.collection('Assigndate').doc(widget.id).update({
      "status": newStatus,
    });

    setState(() {
      currentStatus = newStatus; // Update the local state to reflect the change
    });
  }

  // Fetch questions from Firestore
  Future<List<Map<String, dynamic>>> fetchQuizQuestions() async {
    QuerySnapshot snapshot = await _firestore
        .collection('quiz_questions')
        .where("dateAdded", isEqualTo: widget.date)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'question': doc['question'],
        'options': List<String>.from(doc['options']),
        'correctOption': doc['correctOption'],
        'dateAdded': doc['dateAdded'],
      };
    }).toList();
  }

  // Update a question in Firestore
  Future<void> updateQuestion(
      String id, String question, List<String> options, int correctOption) async {
    await _firestore.collection('quiz_questions').doc(id).update({
      'question': question,
      'options': options,
      'correctOption': correctOption,
    });
  }

  // Delete a question from Firestore
  Future<void> deleteQuestion(String id) async {
    await _firestore.collection('quiz_questions').doc(id).delete();
    setState(() {}); // Refresh the UI after deleting a question
  }

  // Show a dialog to edit a question
  Future<void> showUpdateDialog(BuildContext context, String id, String question,
      List<String> options, int correctOption) async {
    TextEditingController questionController =
    TextEditingController(text: question);
    List<TextEditingController> optionControllers = List.generate(
      options.length,
          (index) => TextEditingController(text: options[index]),
    );
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
                    decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                  );
                }),
                TextField(
                  controller: correctOptionController,
                  decoration: InputDecoration(labelText: 'Correct Option Index'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                List<String> updatedOptions =
                optionControllers.map((c) => c.text).toList();
                int updatedCorrectOption =
                int.parse(correctOptionController.text);

                updateQuestion(
                  id,
                  questionController.text,
                  updatedOptions,
                  updatedCorrectOption,
                );

                Navigator.pop(context); // Close the dialog
                setState(() {}); // Refresh the UI after update
              },
              child: Text('Save', style: TextStyle(color: Colors.green)),
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
          InkWell(
            onTap: toggleStatus, // Toggle status on tap
            child: Container(
              color: currentStatus == 0 ? Colors.green : Colors.red,
              height: 50,
              width: 200,
              child: Center(
                child: Text(
                  currentStatus == 0 ? "Tap to publish" : "Unpublish",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuizQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions found'));
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
                        Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            question['options'].length,
                                (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${i + 1}. ${question['options'][i]}'),
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
                                deleteQuestion(question['id']);
                              },
                            ),
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

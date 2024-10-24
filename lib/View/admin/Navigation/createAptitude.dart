import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../ViewModel/admin/QuestionProvider.dart';
import 'add_question_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<QuestionProvider>(context, listen: false).loadQuestions();
  }

  Future<void> _submitQuestions() async {
      await Provider.of<QuestionProvider>(context, listen: false)
          .submitQuestionsToFirebase(selecteddata: selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Questions submitted successfully!')),
      );


  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        title: Text(
          'Aptitude Scheduler',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Date: ${selectedDate ?? "No date selected"}",
              style: TextStyle(color: Colors.black),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: questionProvider.questions.isEmpty
                  ? Center(child: Text('No questions added yet.'))
                  : ListView.builder(
                      itemCount: questionProvider.questions.length,
                      itemBuilder: (context, index) {
                        final question = questionProvider.questions[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${index + 1}.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      question['question'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                SizedBox(height: 10),
                                ...List.generate(question['options'].length,
                                    (i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Text('Option ${i + 1}: '),
                                        Expanded(
                                          child: Text(
                                            question['options'][i],
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                SizedBox(height: 10),
                                Text(
                                  'Correct Option: Option ${question['correctOption'] + 1}',
                                  style: TextStyle(color: Colors.green),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Date Added: ${question['dateAdded']}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        questionProvider.deleteQuestion(index);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 100),
            //   child: GestureDetector(
            //     onTap: () => _submitQuestions,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Container(
            //           height: 50, // Adjust the height as needed
            //           width: 200, // Adjust the width as needed
            //           padding:
            //               const EdgeInsets.all(16.0), // Add padding for spacing
            //           decoration: BoxDecoration(
            //             color: Colors.blue.shade900,
            //             // Optional border
            //             borderRadius: BorderRadius.circular(
            //                 8.0), // Optional rounded corners
            //           ),
            //           child: Center(
            //               child: Text(
            //             "Submit To Firebase",
            //             style: TextStyle(color: Colors.white),
            //           )),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            ElevatedButton(
              onPressed: _submitQuestions,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18)),
              child: Center(
                child: Text('Submit Questions to Firebase'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (selectedDate != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddQuestionPage(
                  quizDate: selectedDate,
                  onQuestionAdded: () => questionProvider.loadQuestions(),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('First pick your date')),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

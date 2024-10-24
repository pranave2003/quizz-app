import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzapp/View/admin/Navigation/Aptitude/viewQuastions.dart';

class AptitudePage extends StatefulWidget {
  const AptitudePage({super.key});

  @override
  State<AptitudePage> createState() => _AptitudePageState();
}

class _AptitudePageState extends State<AptitudePage> {
  // Function to delete a document by its ID
  Future<void> deleteAssignedDate(String docId) async {
    await FirebaseFirestore.instance
        .collection('Assigndate')
        .doc(docId)
        .delete();
  }

  // Function to count the number of questions for a specific date
  Future<int> countQuestionsByDate(String date) async {
    QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
        .collection('quiz_questions')
        .where('dateAdded', isEqualTo: date)
        .get();
    return questionSnapshot.size; // Returns the number of questions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: Text("Scheduled Date"),
      ),
      backgroundColor: Colors.blue.shade50,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Assigndate').snapshots(),
        builder: (context, quizSnapshot) {
          if (quizSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          } else if (quizSnapshot.hasError) {
            return Center(child: Text('Error: ${quizSnapshot.error}'));
          }

          var quizzes = quizSnapshot.data!.docs;
          Set<String> uniqueDates = {}; // Store unique dates

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              var quiz = quizzes[index];
              var assignedDate = quiz["Assigneddate"];
              var docId = quiz.id; // Get the document ID for deleting

              // Skip if the date is already encountered
              if (uniqueDates.contains(assignedDate)) {
                return SizedBox.shrink(); // Skip rendering this item
              }
              // Add the date to the set, ensuring it won't appear again
              uniqueDates.add(assignedDate);

              return FutureBuilder<int>(
                future: countQuestionsByDate(assignedDate), // Fetch question count
                builder: (context, countSnapshot) {
                  if (!countSnapshot.hasData) {
                    return ListTile(
                      title: Text(assignedDate),
                      subtitle: Text("Loading question count..."),
                    );
                  }

                  int questionCount = countSnapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(color: Colors.white,
                      child: ListTile(
                        title: Text(
                          assignedDate,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                            "$questionCount questions added"), // Show question count
                        trailing: IconButton(
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
                                      'Are you sure you want to delete this date?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteAssignedDate(docId); // Delete the date
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return QuizQuestionsPage(date: assignedDate);
                            }),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

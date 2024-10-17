import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_result_page.dart';

class UserQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User - Take Quiz')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Assigndate').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          var quizzes = snapshot.data!.docs;
          Set<String> uniqueDates = {}; // Store unique dates

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              var quiz = quizzes[index];
              var assignedDate = quiz["Assigneddate"];

              // Check if the date is already in the set
              if (uniqueDates.contains(assignedDate)) {
                return SizedBox.shrink(); // Skip this quiz if date is duplicate
              }

              // Add the date to the set to mark it as encountered
              uniqueDates.add(assignedDate);

              return ListTile(
                title: Text('Quiz ${index + 1}'),
                subtitle: Text(assignedDate),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuizPage(assignedDate: quiz["Assigneddate"].toString(),)));
                },
              );
            },
          );
        },
      ),
    );
  }
}

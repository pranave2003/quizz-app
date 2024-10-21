import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:quizzapp/View/students/quiz/quiz_result_page.dart';

import '../../ViewModel/user/userdetails.dart'; // Adjust this import path as needed.

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return StreamBuilder<DocumentSnapshot>(
            stream: userProvider.userStream,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}'));
              } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Center(child: Text('No data available'));
              } else {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final imageUrl = userData['imageUrl'] ?? '';
                final name = userData['name'] ?? '';
                final trade = userData['Trade'] ?? '';
                final location = userData['OfficeLocation'] ?? '';
                final userid = userData['userId'] ?? '';
                final emailid = userData['email'] ?? '';


                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Hi.. $name",
                                style: GoogleFonts.aboreto(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(radius: 50),
                          CircleAvatar(radius: 50),
                          CircleAvatar(radius: 50),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Assigndate')
                              .snapshots(),
                          builder: (context, quizSnapshot) {
                            if (quizSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (quizSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${quizSnapshot.error}'));
                            }

                            var quizzes = quizSnapshot.data!.docs;
                            Set<String> uniqueDates = {}; // Store unique dates

                            return ListView.builder(
                              itemCount: quizzes.length,
                              itemBuilder: (context, index) {
                                var quiz = quizzes[index];
                                var assignedDate = quiz["Assigneddate"];

                                // Skip if the date is already encountered
                                if (uniqueDates.contains(assignedDate)) {
                                  return SizedBox.shrink();
                                }

                                uniqueDates
                                    .add(assignedDate); // Add date to set
                                double exampleProgress =
                                    60 * 0.01; // 0.2, 0.4, etc.

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return QuizPage(
                                            assignedDate:
                                                quiz["Assigneddate"].toString(),
                                            Userid: userid,
                                          trade:trade,
                                          location:location,
                                          email:emailid,
                                          image:imageUrl,

                                        );
                                      },
                                    ));
                                  },
                                  child: Card(
                                   child:  FutureBuilder(
                                     future: FirebaseFirestore.instance.collection("Submitanswer").where("userid",isEqualTo: userid).get(),
                                     builder: (context, snapshot) {
                                       if (snapshot.connectionState == ConnectionState.waiting) {
                                         return Center(
                                           child: CircularProgressIndicator(),
                                         );
                                       }
                                       if (snapshot.hasError) {
                                         return Center(
                                           child: Text("Error:${snapshot.error}"),
                                         );
                                       }


                                       return Column(
                                         children: [
                                           Row(
                                             mainAxisAlignment:
                                             MainAxisAlignment.spaceEvenly,
                                             children: [
                                               Text(
                                                 "Aptitude ${index + 1}",
                                                 style: TextStyle(fontSize: 25),
                                               ),
                                               SizedBox(width: 100),
                                               Padding(
                                                 padding:
                                                 const EdgeInsets.all(8.0),
                                                 child: CircularPercentIndicator(
                                                   radius: 40.0,
                                                   lineWidth: 5.0,
                                                   percent: exampleProgress,
                                                   center: Text("0/100"),
                                                   progressColor: Colors.grey,
                                                 ),
                                               ),
                                             ],
                                           ),
                                           Row(
                                             mainAxisAlignment:
                                             MainAxisAlignment.spaceBetween,
                                             children: [
                                               Padding(
                                                 padding:
                                                 const EdgeInsets.all(8.0),
                                                 child: Row(
                                                   children: [
                                                     Text("Performance: "),
                                                     Text(
                                                       "pending",
                                                       style: TextStyle(
                                                           color: Colors.green),
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                               Padding(
                                                 padding: const EdgeInsets.only(
                                                     right: 30),
                                                 child: Text(
                                                   assignedDate,
                                                   style: TextStyle(
                                                       color: Colors.red),
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ],
                                       );
                                     },

                                   ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

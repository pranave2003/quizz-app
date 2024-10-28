import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:quizzapp/View/students/quiz/quiz_result_page.dart';

import '../../ViewModel/user/Auth.dart';
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
      backgroundColor: Colors.black,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return StreamBuilder<DocumentSnapshot>(
            stream: userProvider.userStream,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.red,
                ));
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
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 200.h,
                            width: 300.w,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(30),
                                    topLeft: Radius.circular(30))),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(imageUrl),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        " $name",
                                        style: GoogleFonts.aboreto(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "$trade",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        height: 30,
                      ),
                      // ListView of quizzes
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Assigndate')
                              .where("status", isEqualTo: 1)
                              .snapshots(),
                          builder: (context, quizSnapshot) {
                            if (quizSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: CircularProgressIndicator(
                                color: Colors.red,
                              ));
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

                                // Check if user has attended the quiz on this date
                                return FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection("Submitanswer")
                                      .where("userid", isEqualTo: userid)
                                      .where("Assigneddate",
                                          isEqualTo: assignedDate)
                                      .get(),
                                  builder: (context, attendanceSnapshot) {
                                    if (attendanceSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.red,
                                      ));
                                    }
                                    if (attendanceSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              "Error: ${attendanceSnapshot.error}"));
                                    }

                                    var attended = attendanceSnapshot
                                        .data!.docs.isNotEmpty;
                                    var score = attended
                                        ? attendanceSnapshot
                                            .data!.docs.first["scrore"]
                                        : 0;

                                    var progress = attended ? score / 100 : 0.0;
                                    var statusText = attended ? "" : "Pending";

                                    return GestureDetector(
                                      onTap: () {
                                        if (!attended) {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "Notice",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text(
                                                          "1.Please read carefully each question, and finally, you will choose the correct option."),
                                                      SizedBox(height: 8),
                                                      Text(
                                                          "2. Each question carries 4 marks, for a total of 25 questions."),
                                                      SizedBox(height: 8),
                                                      Text(
                                                          "3. You will have a single attempt to answer the questions."),
                                                      SizedBox(height: 30),
                                                      Center(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                                return QuizPage(
                                                                  assignedDate:
                                                                      quiz["Assigneddate"]
                                                                          .toString(),
                                                                  userId:
                                                                      userid,
                                                                  trade: trade,
                                                                  location:
                                                                      location,
                                                                  email:
                                                                      emailid,
                                                                  image:
                                                                      imageUrl,
                                                                  name: name,
                                                                );
                                                              },
                                                            ));
                                                          },
                                                          child: Container(
                                                            width: 200,
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Center(
                                                                child: Text(
                                                              "Start Quiz",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 100,
                                                      )
                                                    ],
                                                  ),
                                                );
                                              });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "You have already attended this quiz."),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          color: attended
                                              ? Colors.green.shade50
                                              : Colors.grey.shade200,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                        color: attended
                                                            ? Colors
                                                                .green.shade900
                                                            : Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Center(
                                                      child: attended
                                                          ? Text(
                                                              "Done",
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  color: Colors
                                                                      .white),
                                                            )
                                                          : Text(
                                                              "TRY",
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 100),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        CircularPercentIndicator(
                                                      radius: 40.0,
                                                      lineWidth: 5.0,
                                                      percent: progress,
                                                      center:
                                                          Text("$score/100"),
                                                      progressColor: attended
                                                          ? Colors.green
                                                          : Colors
                                                              .grey.shade900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          statusText,
                                                          style: TextStyle(
                                                              color: attended
                                                                  ? Colors.green
                                                                  : Colors.red),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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

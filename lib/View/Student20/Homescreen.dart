import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:quizzapp/View/admin/Navigation/Result/Redult_sheduledate.dart';
import 'package:quizzapp/View/students/quiz/quiz_result_page.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import '../../ViewModel/user/Auth.dart';
import '../../ViewModel/user/userdetails.dart';
import 'Fav/Fav.dart'; // Adjust this import path as needed.

class StudentHome20 extends StatefulWidget {
  const StudentHome20({super.key});

  @override
  State<StudentHome20> createState() => _StudentHome20State();
}

class _StudentHome20State extends State<StudentHome20> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mycolor1, mycolor2],
          )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "IQ",
              style: GoogleFonts.abrilFatface(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white),
            ),
          ),
        ),
        // ... other AppBar properties
      ),
      backgroundColor: Colors.white,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return StreamBuilder<DocumentSnapshot>(
            stream: userProvider.userStream,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.yellow,
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
                                color: mycolor,
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
                                    var statusText =
                                        attended ? "Attended" : "Pending";

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
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15, bottom: 20),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: attended
                                                ? Colors.white
                                                : Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                              topRight: Radius.circular(60),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: mycolor2, // Shadow color
                                                spreadRadius:
                                                    2, // Spread radius
                                                blurRadius: 5, // Blur radius
                                                offset: Offset(0,
                                                    3), // Offset in x and y direction
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                              ),
                                              attended
                                                  ? SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Aptitude ${index + 1}",
                                                                        style: GoogleFonts.abrilFatface(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                30,
                                                                            color:
                                                                                Colors.black87),
                                                                      ),
                                                                      Divider(color: Colors.black,),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                              width: 80,
                                                                              child: Text("Date :")),
                                                                          Text(
                                                                              assignedDate),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                              width: 80,
                                                                              child: Text("Status :")),
                                                                          Text(
                                                                            statusText,
                                                                            style:
                                                                                TextStyle(color: Colors.green),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    width: 50,
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          AnimatedLiquidCircularProgressIndicator(
                                                              TextColor:
                                                                  Colors.green,
                                                              bagroundcolor:
                                                                  mycolor3,
                                                              watercolor:
                                                                  mycolor2,
                                                              score: score),
                                                          SizedBox(
                                                            width: 20,
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Aptitude ${index + 1}",
                                                                style: GoogleFonts.abrilFatface(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: Colors
                                                                        .black87),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: 80,
                                                                      child: Text(
                                                                          "Date :")),
                                                                  Text(
                                                                      assignedDate),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: 80,
                                                                      child: Text(
                                                                          "Status :")),
                                                                  Text(
                                                                    statusText,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 50,
                                                          ),
                                                          AnimatedLiquidCircularProgressIndicator(
                                                              TextColor:
                                                                  Colors.green,
                                                              bagroundcolor:
                                                                  Colors.grey,
                                                              watercolor:
                                                                  Colors.grey,
                                                              score: 0),
                                                          SizedBox(
                                                            width: 20,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              attended
                                                  ? MyButton(
                                                      height: 50,
                                                      width: 200,
                                                      text: "Done",
                                                      onPressed: () {},
                                                    )
                                                  : MyButton(
                                                      height: 50,
                                                      width: 200,
                                                      text: "Try",
                                                      onPressed: () {},
                                                    ),
                                              SizedBox(
                                                height: 20,
                                              )
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

class AnimatedLiquidCircularProgressIndicator extends StatelessWidget {
  final double score; // Pass score as a value between 0 and 100

  final Color TextColor;
  final Color watercolor;
  final Color bagroundcolor;

  AnimatedLiquidCircularProgressIndicator({
    required this.score,
    required this.TextColor,
    required this.bagroundcolor,
    required this.watercolor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score.clamp(0, 100); // Ensure score is between 0 and 100

    return SizedBox(
      width: 100.0,
      height: 100.0,
      child: LiquidCircularProgressIndicator(
        value: percentage / 100, // Convert score to a fraction
        backgroundColor: bagroundcolor,
        valueColor: AlwaysStoppedAnimation(watercolor),
        center: Text(
          "${percentage.toStringAsFixed(0)}/100", // Show percentage as text
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

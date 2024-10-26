import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  // Load userId from SharedPreferences
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Your Result",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: userId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Submitanswer')
                  .where('userid', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var results = snapshot.data!.docs;

                if (results.isEmpty) {
                  return Center(child: Text("No results available."));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    var data = results[index].data() as Map<String, dynamic>;
                    int score = int.parse("${data['scrore']}");
                    return Card(
                      child: ListTile(
                        title: Text(
                          "Score: ${data['scrore']}",
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Assigned Date: ${data['Assigneddate']}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                score == 0
                                    ? Text(
                                        "Week Perfomance 😡",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : score <= 30
                                        ? Text(
                                            "Need Improve",
                                            style: TextStyle(
                                                color: Colors.amber.shade900,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : score <= 70
                                            ? Text(
                                                "Average Performance",
                                                style: TextStyle(
                                                    color:
                                                        Colors.green.shade900),
                                              )
                                            : Text(
                                                "Good Performance 🥳",
                                                style: TextStyle(
                                                    color:
                                                        Colors.green.shade900,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

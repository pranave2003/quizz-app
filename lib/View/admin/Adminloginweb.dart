import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'Admindashboard.dart';

class AdminLoginweb extends StatefulWidget {
  const AdminLoginweb({super.key});

  @override
  State<AdminLoginweb> createState() => _AdminLoginwebState();
}

class _AdminLoginwebState extends State<AdminLoginweb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.blue.shade50, Colors.black])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 400,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            LottieBuilder.asset(
                              'assets/Animation - 1729684673816.json', // Replace with your Lottie file path
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                "IQ",
                                style: GoogleFonts.abrilFatface(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                // Use Expanded to fill available width
                                child: Text(
                                  "dbsbfdbsj sabkjsbdajkdas jdahsbdjshbdajd sdjhdbajdhbdjhbda sjhbashjdbsdhjabdajsb asajdbjdbdjahb ksdnakdnakd. ",
                                  maxLines: null,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  width: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.black]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          " ADMIN LOGIN",
                          style: GoogleFonts.abrilFatface(
                              color: Colors.white, fontSize: 20),
                        ),
                        TextFormField(
                          decoration: InputDecoration(hintText: "Username"),
                        ),
                        TextFormField(
                          decoration: InputDecoration(hintText: "Password"),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        GestureDetector(onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) {
                            return DashboardScreen();
                          },));
                        },
                          child: Container(
                            height: 50, // Adjust the height as needed
                            width: 200, // Adjust the width as needed
                            padding: const EdgeInsets.all(
                                16.0), // Add padding for spacing
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              // Optional border
                              borderRadius: BorderRadius.circular(
                                  8.0), // Optional rounded corners
                            ),
                            child: Center(child: Text("Login")),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Homescreen.dart';
import 'Login.dart';

class Gauth extends StatefulWidget {
  const Gauth({super.key});

  @override
  State<Gauth> createState() => _GauthState();
}

class _GauthState extends State<Gauth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is logged in
            if (snapshot.hasData) {
              return const StudentHome();
            }
            //user is notlogged in
            else {
              return Login();
            }
          }),
    );
  }
}
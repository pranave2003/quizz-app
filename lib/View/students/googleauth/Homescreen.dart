import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Googlelogin.dart';

class GoogleHome extends StatefulWidget {
  const GoogleHome({super.key});

  @override
  State<GoogleHome> createState() => _GoogleHomeState();
}

class _GoogleHomeState extends State<GoogleHome> {
  logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Googlelogin(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(
              Icons.login,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AdminLoginweb.dart';
import 'Admindashboard.dart';

class AdminAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is authenticated
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          // If there is a user, navigate to the Dashboard, else show the login page
          if (user != null) {
            return DashboardScreen(); // Replace with your actual Dashboard widget
          } else {
            return AdminLoginweb(); // Replace with your login screen widget
          }
        }

        // Show a loading indicator while checking the auth state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../View/students/Homescreen.dart';
import '../View/students/Login.dart';

class Auth extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String userId = userCredential.user!.uid;
        String email = userCredential.user!.email ?? "";

        // Check if the user's email exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('Softstudents')
            .where('email', isEqualTo: email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          // User already exists, navigate to home screen
          prefs.setString('userId', userId);
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return StudentHome();
            },
          ));
        } else {
          // New user, save data and show the registration dialog
          prefs.setString('userId', userId);

          String name = userCredential.user!.displayName ?? "";
          String imageUrl = userCredential.user!.photoURL ?? "";

          // Show dialog for registering the user
          showAlert(context, name, email, imageUrl, userId);
        }
      }
    } catch (error) {
      print("Google sign-in error: $error");
      // Optionally show an error dialog
    }
  }

  final List<String> trades = ['FLUTTER', 'MERN', 'PYTHON', 'DIGITAL_MARKET'];
  final List<String> locations = [
    'KOZHIKODE',
    'PERINTHALMANNA',
    'PALAKKAD',
    'KOCHI'
  ];

  Future<void> showAlert(BuildContext context, String name, String email,
      String image, String userId) async {
    // Define variables to hold selected values
    String? selectedTrade;
    String? selectedLocation;

    // Display the AlertDialog
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder allows you to manage state within the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Register User'),
              content: SingleChildScrollView(
                // SingleChildScrollView ensures content is scrollable if it overflows
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display user information
                    Text("Name: $name"),
                    SizedBox(height: 8),
                    Text("Email: $email"),
                    SizedBox(height: 16),

                    // Dropdown for Trade Selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Trade',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedTrade,
                      items: trades.map((trade) {
                        return DropdownMenuItem(
                          value: trade,
                          child: Text(trade),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTrade = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a trade' : null,
                    ),
                    SizedBox(height: 16),

                    // Dropdown for Office Location Selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Office Location',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedLocation,
                      items: locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a location' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // Validate selections
                    if (selectedTrade == null || selectedLocation == null) {
                      // Show a SnackBar or another dialog to inform the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Please select both Trade and Office Location."),
                        ),
                      );
                      return;
                    }

                    // Add user data to Firestore with selected Trade and Location
                    await FirebaseFirestore.instance
                        .collection("Softstudents")
                        .doc(userId)
                        .set({
                      "name": name,
                      "email": email,
                      "imageUrl": image,
                      "userId": userId,
                      "Trade": selectedTrade,
                      "OfficeLocation": selectedLocation,
                    });
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) {
                        return StudentHome();
                      },
                    ));
                    // Optionally, show a confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Registration Successful!")),
                    );

                    // Close the dialog

                    // Optionally, navigate to another screen
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
                  },
                  child: Text('Register'),
                ),
              ],
            );
          },
        );
      },
    );
  }

//   log out

  logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
  }

//   Loading

  loading(isloding) async {
    if (isloding) {
      return CircularProgressIndicator();
    }
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}

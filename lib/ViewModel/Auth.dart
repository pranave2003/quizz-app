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
              backgroundColor: Colors.blue.shade50,
              title: Text('Select Details'),
              content: SingleChildScrollView(
                // SingleChildScrollView ensures content is scrollable if it overflows
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                GestureDetector(
                  onTap: () async {
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
                  },
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                    ),
                    child: Center(
                        child: Text(
                      "SUBMIT",
                      style: TextStyle(fontSize: 25),
                    )),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //  siging with credential
  // Future<dynamic> Sigingwithcredential (BuildContext context, String name, String email, String password,
  //     String selectedTrade, String selectedLocation) async
  // {
  //   try {
  //     final credential =
  //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     await FirebaseFirestore.instance
  //         .collection('Softstudents')
  //         .doc(credential.user!.uid)
  //         .set({
  //       "name": name,
  //       "email": email,
  //       "imageUrl": "image",
  //       "userId": credential.user!.uid,
  //       "Trade": selectedTrade,
  //       "OfficeLocation": selectedLocation,
  //     });
  //
  //     Navigator.push(context, MaterialPageRoute(
  //       builder: (context) {
  //         return Login();
  //       },
  //     ));
  //     print("Added success");
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //             "The password provided is too weak",
  //             style: TextStyle(color: Colors.amberAccent),
  //           )));
  //       print('The password provided is too weak.');
  //     } else if (e.code == 'email-already-in-use') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //             "he account already exists for that email.",
  //             style: TextStyle(color: Colors.red),
  //           )));
  //       print('The account already exists for that email.');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // sighin with credential login
  // Future<void> Credentiallogin(BuildContext context, String email,String password,) async {
  //   try {
  //
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     print("done");
  //     final user = await FirebaseFirestore.instance
  //         .collection('Softstudents')
  //         .where('email', isEqualTo: email)
  //         .where('password', isEqualTo: password)
  //         .get();
  //     if (user.docs.isNotEmpty) {
  //       String  userid = user.docs[0].id;
  //
  //       SharedPreferences data = await SharedPreferences.getInstance();
  //       data.setString('userId', userid);
  //       Navigator.pushReplacement(context, MaterialPageRoute(
  //         builder: (context) {
  //           return StudentHome();
  //         },
  //       ));
  //     }
  //
  //
  //
  //   } on FirebaseAuthException catch (e) {
  //
  //
  //     print("error is $e");
  //
  //     if (e.code == 'invalid-email') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //             "The email address is badly formatted",
  //             style: TextStyle(color: Colors.white),
  //           )));
  //       // Handle user not found error
  //     }
  //     if (e.code == 'invalid-credential') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //             " incorrect  username and password ",
  //             style: TextStyle(color: Colors.red),
  //           )));
  //       // Handle user not found error
  //     } else if (e.code == 'too-many-requests') {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //             "We have blocked all requests from this device due to unusual activity",
  //             style: TextStyle(color: Colors.white),
  //           )));
  //     }
  //   }
  // }

//   log out

  logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
    notifyListeners();
  }

//   Loading

  FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  // Constructor to check if a user is already logged in
  AuthProvider() {
    _user = _auth.currentUser;
  }

  // Sign up function
  Future<void> signUpWithCredentials(BuildContext context, String name, String email, String password,
      String selectedTrade, String selectedLocation) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;

      await FirebaseFirestore.instance.collection('Softstudents')
          .doc(_user!.uid).set({
        "name": name,
        "email": email,
        "imageUrl": "image",
        "userId": _user!.uid,
        "Trade": selectedTrade,
        "OfficeLocation": selectedLocation,
      });

      // Navigate to Login screen after successful registration
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));

      notifyListeners(); // Notify listeners about authentication state change
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "The password provided is too weak.",
            style: TextStyle(color: Colors.amberAccent),
          ),
        ));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "The account already exists for that email.",
            style: TextStyle(color: Colors.red),
          ),
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  // Login function
  Future<void> loginWithCredentials(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;

      if (_user != null) {
        // Navigate to Home screen after successful login
        Navigator.push(context, MaterialPageRoute(builder: (context) => StudentHome()));

        notifyListeners(); // Notify listeners about authentication state change
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "No user found for that email.",
            style: TextStyle(color: Colors.red),
          ),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Wrong password provided.",
            style: TextStyle(color: Colors.red),
          ),
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  // Sign out function
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    _user = null;
    notifyListeners(); // Notify listeners when the user logs out
  }











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

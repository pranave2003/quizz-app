import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ViewModel/Auth.dart';


class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  String? userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Call this method to load user ID when the screen initializes
  }

  // Method to get the user ID from shared preferences
  Future<void> _loadUserId() async {
    setState(() {
      _isLoading = true; // Set loading to true while fetching data
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs
          .getString('userId'); // Retrieve the user ID with the key 'userId'
      _isLoading = false; // Set loading to false once data is fetched
    });

    if (userId != null) {
      print('User ID: $userId'); // Print the user ID in the console
    } else {
      print('No user ID found in shared preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.add)),
        backgroundColor: Colors.blue.shade50,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // Log out the user when the button is pressed
              Provider.of<Auth>(context, listen: false).logout(context);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator while data is being fetched
            : Text(
                userId != null ? 'User ID: $userId' : 'No User ID Found',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}

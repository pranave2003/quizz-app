import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String userId = '';


  UserProvider() {
    _loadUserId();
  }

  // Function to load the user ID from SharedPreferences
  Future<void> _loadUserId() async {
    print("Load user data from UserProvider");
    SharedPreferences data = await SharedPreferences.getInstance();
    userId = data.getString('userId') ?? '';
    print("User ID: $userId");
    notifyListeners(); // Notify listeners to rebuild UI if needed
  }

  // Function to fetch the Firestore stream for the user's document
  Stream<DocumentSnapshot> get userStream {
    if (userId.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection("Softstudents")
          .doc(userId)
          .snapshots();
    } else {
      // Return an empty stream if userId is not set
      return Stream.empty();
    }
  }
}

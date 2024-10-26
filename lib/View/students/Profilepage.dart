import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/user/Auth.dart';
import '../../ViewModel/user/userdetails.dart'; // Adjust path to match your folder structure

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'IQ',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<Auth>(context, listen: false).signOut(context);
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ))
        ],
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userProvider.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No user data found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['imageUrl'] != null
                      ? NetworkImage(userData['imageUrl'])
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
                SizedBox(height: 16),

                // User Name
                Text(
                  userData['name'] ?? 'Unknown Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
                SizedBox(height: 8),

                // User Email
                Text(
                  userData['email'] ?? 'No email available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,

                  ),
                ),
                SizedBox(height: 16),

                // User Details Section
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileRow(
                            "Location", userData['OfficeLocation']),
                        _buildProfileRow("Trade", userData['Trade']),
                        _buildProfileRow(
                            "Email", userData['email']?.toString() ?? 'N/A'),
                      ],
                    ),
                  ),
                ),

                // Edit Profile Button
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Text(value ?? 'N/A'),
        ],
      ),
    );
  }
}

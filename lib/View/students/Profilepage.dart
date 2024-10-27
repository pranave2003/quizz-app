import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ViewModel/user/Auth.dart';
import '../../ViewModel/user/userdetails.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
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
            ),
          ),
          IconButton(
            onPressed: () => _showEditDialog(context, userProvider),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData['imageUrl'] != null
                        ? NetworkImage(userData['imageUrl'])
                        : AssetImage('assets/default_profile.png')
                            as ImageProvider,
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData['name'] ?? 'Unknown Name',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userData['email'] ?? 'No email available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
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
                          SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage("assets/img.png"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (userData["Linkdin"] == "") {
                                    print("null data please add");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "First Add your Linkedin link")),
                                    );
                                  } else {
                                    final uri = Uri.parse(userData["Linkdin"]);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      throw 'Could not launch';
                                    }
                                  }
                                },
                                child: Text("Open LinkedIn"),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage("assets/img_1.png"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (userData["github"] == "") {
                                    print("null data please add");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "First Add your github link")),
                                    );
                                  } else {
                                    final uri = Uri.parse(userData["github"]);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      throw 'Could not launch';
                                    }
                                  }
                                },
                                child: Text("Open GitHub"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

  void _showEditDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController linkedInController = TextEditingController();
    final TextEditingController githubController = TextEditingController();

    userProvider.userStream.listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        nameController.text = userData['name'] ?? '';
        linkedInController.text = userData['Linkdin'] ?? 'Add LinkedIn';
        githubController.text = userData['github'] ?? 'Add GitHub';
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade50,
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: linkedInController,
                  decoration: InputDecoration(labelText: 'LinkedIn'),
                ),
                TextField(
                  controller: githubController,
                  decoration: InputDecoration(labelText: 'GitHub'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_isValidUrl(linkedInController.text) &&
                    _isValidUrl(githubController.text)) {
                  // If URLs are valid, update the profile
                  await FirebaseFirestore.instance
                      .collection('Softstudents')
                      .doc(userProvider.userId)
                      .update({
                    'name': nameController.text,
                    'Linkdin': linkedInController.text,
                    'github': githubController.text,
                  });
                  Navigator.of(context).pop();
                } else {
                  // Show an error message if URLs are invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please enter valid URLs for LinkedIn and GitHub.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );

// URL validation function
  }

  bool _isValidUrl(String url) {
    final urlPattern =
        r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9]+)([a-zA-Z0-9._-]+)\.([a-zA-Z]{2,6})(\/[a-zA-Z0-9._-]*)*\/?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(url);
  }

  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

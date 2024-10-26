import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminNotificationScreen extends StatefulWidget {
  @override
  _AdminNotificationScreenState createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController matterController = TextEditingController();

  // Method to add a new notification to Firestore
  Future<void> addNotification() async {
    String content = contentController.text.trim();
    String matter = matterController.text.trim();

    if (content.isNotEmpty && matter.isNotEmpty) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm').format(now);

      await FirebaseFirestore.instance.collection('Notifications').add({
        'content': content,
        'matter': matter,
        'date': formattedDate,
        'time': formattedTime,
      });

      contentController.clear();
      matterController.clear();
    }
  }

  // Method to update an existing notification
  Future<void> updateNotification(String docId) async {
    String content = contentController.text.trim();
    String matter = matterController.text.trim();

    if (content.isNotEmpty && matter.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(docId)
          .update({
        'content': content,
        'matter': matter,
      });
    }
  }

  // Method to delete a notification
  Future<void> deleteNotification(String docId) async {
    await FirebaseFirestore.instance
        .collection('Notifications')
        .doc(docId)
        .delete();
  }

  // Show a dialog for adding or editing a notification
  void showAddEditNotificationDialog(
      {String? docId, String? existingContent, String? existingMatter}) {
    contentController.text = existingContent ?? '';
    matterController.text = existingMatter ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add Notification' : 'Edit Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: matterController,
                decoration: InputDecoration(labelText: 'Matter'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (docId == null) {
                  addNotification();
                } else {
                  updateNotification(docId);
                }
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade50,
          title: Text('Notifications'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Notifications')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var notifications = snapshot.data!.docs;

            if (notifications.isEmpty) {
              return Center(child: Text('No notifications available.'));
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var data = notifications[index].data() as Map<String, dynamic>;
                String docId = notifications[index].id;

                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      data['content'] ?? 'No Content',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['matter'] ?? 'No Matter'),
                        Text("Date: ${data['date']}",style: TextStyle(color: Colors.red),),
                        Text("Time: ${data['time']}",style: TextStyle(color: Colors.green),),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showAddEditNotificationDialog(
                              docId: docId,
                              existingContent: data['content'],
                              existingMatter: data['matter'],
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNotification(docId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
             showAddEditNotificationDialog();
          },
          child: Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                "Add Notification",
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ));
  }
}

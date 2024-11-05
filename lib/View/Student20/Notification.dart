import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen20 extends StatefulWidget {
  @override
  _NotificationScreen20State createState() => _NotificationScreen20State();
}

class _NotificationScreen20State extends State<NotificationScreen20> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .orderBy('date', descending: true) // Order by date
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
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(
                    data['content'] ?? 'No Content',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['matter'] ?? 'No Matter',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Date: ${data['date']}",
                        style: TextStyle(color: Colors.black26),
                      ),
                      Text("Time: ${data['time']}",
                          style: TextStyle(color: Colors.black26)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

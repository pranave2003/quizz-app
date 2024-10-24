import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Model/admin/navigation/mystudentsmodel.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final List<String> trades = ['FLUTTER', 'MERN', 'PYTHON', 'DIGITAL_MARKET'];
  final List<String> locations = [
    'KOZHIKODE',
    'PERINTHALMANNA',
    'PALAKKAD',
    'KOCHI'
  ];

  String? selectedTrade;
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
        backgroundColor: Colors.blue.shade50,
        actions: [
          // Trade Dropdown
          DropdownButton<String>(
            value: selectedTrade,
            hint: Text('Select Trade'),
            onChanged: (value) {
              setState(() {
                selectedTrade = value;
              });
            },
            items: trades.map((String trade) {
              return DropdownMenuItem<String>(
                value: trade,
                child: Text(trade),
              );
            }).toList(),
          ),
          SizedBox(width: 20),
          // Location Dropdown
          DropdownButton<String>(
            value: selectedLocation,
            hint: Text('Select Location'),
            onChanged: (value) {
              setState(() {
                selectedLocation = value;
              });
            },
            items: locations.map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Softstudents').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Filter students based on selected trade and location
          List<MyStudents> students = snapshot.data!.docs
              .map((doc) => MyStudents.fromDocumentSnapshot(doc))
              .where((student) {
            bool matchesTrade = selectedTrade == null || student.trade == selectedTrade;
            bool matchesLocation = selectedLocation == null || student.officeLocation == selectedLocation;
            return matchesTrade && matchesLocation;
          }).toList();

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              MyStudents student = students[index];
              return StudentCard(student: student, index: index); // Pass index to StudentCard
            },
          );
        },
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final MyStudents student;
  final int index;  // Changed type to int for index

  StudentCard({required this.student, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(student.imageUrl),
        ),
        title: Text('${index + 1}. ${student.name}',  // Display index + 1 before name
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${student.email}'),
            Text('Trade: ${student.trade}'),
            Text('Office Location: ${student.officeLocation}'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentResultScreen extends StatefulWidget {
  @override
  _StudentResultScreenState createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  final List<String> trades = [
    'All',
    'FLUTTER',
    'MERN',
    'PYTHON',
    'DIGITAL_MARKET'
  ];
  final List<String> locations = [
    'All',
    'KOZHIKODE',
    'PERINTHALMANNA',
    'PALAKKAD',
    'KOCHI'
  ];
  String? selectedTrade = 'All';
  String? selectedLocation = 'All';
  String? selectedDate = 'All';

  List<String> assignedDates = ['All']; // Initially, "All" is included
  String? selectedAssignedDate;

  @override
  void initState() {
    super.initState();
    fetchAssignedDates();
  }

  // Fetching the assigned dates from Firestore
  Future<void> fetchAssignedDates() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Assigndate').get();
    List<String> dates =
        snapshot.docs.map((doc) => doc['Assigneddate'].toString()).toList();

    setState(() {
      assignedDates.addAll(dates); // Adding fetched dates to the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade100,
          title: Text('Student Results'),
        ),
        body: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [

                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Trade: "),
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
                  ],
                ),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Location: "),
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
                  ],
                ),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Choose Date"),
                    DropdownButton<String>(
                      value: selectedAssignedDate,
                      hint: Text('Select Date'),
                      onChanged: (value) {
                        setState(() {
                          selectedAssignedDate = value;
                        });
                      },
                      items: assignedDates.map((String date) {
                        return DropdownMenuItem<String>(
                          value: date,
                          child: Text(date),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Submitanswer')
                    .where('Assigneddate',
                        isEqualTo: selectedAssignedDate != 'All'
                            ? selectedAssignedDate
                            : null)
                    .where('trade',
                        isEqualTo:
                            selectedTrade != 'All' ? selectedTrade : null)
                    .where('location',
                        isEqualTo:
                            selectedLocation != 'All' ? selectedLocation : null)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(child: Text('No results found.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      return Card(color: Colors.white,
                        child: ListTile(
                          title: Text("User: ${data['userid']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Location: ${data['location']}"),
                              Text("Trade: ${data['trade']}"),
                              Text("Score: ${data['scrore']}"),
                              Text("Email: ${data['email']}"),
                            ],
                          ),
                          leading: data['image'] != null
                              ? Image.network(data['image'])
                              : Icon(Icons.person),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}

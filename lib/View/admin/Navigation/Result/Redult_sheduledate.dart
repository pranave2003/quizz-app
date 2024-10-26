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
  List<String> assignedDates = ['All'];
  String? selectedAssignedDate;
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchAssignedDates();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.trim();
      });
    });
  }

  Future<void> fetchAssignedDates() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Assigndate')
        .where("status", isEqualTo: 1)
        .get();
    List<String> dates =
    snapshot.docs.map((doc) => doc['Assigneddate'].toString()).toList();
    setState(() {
      assignedDates.addAll(dates);
    });
  }

  Future<void> deleteResult(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Submitanswer')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Result deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete result: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: Text('Student Results'),
      ),
      body: Column(
        children: [
          // Search TextField
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.blue.shade900,
                      filled: true,
                      hintText: "Search Students",
                      hintStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Trade Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  // Location Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  // Date Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  isEqualTo: selectedTrade != 'All' ? selectedTrade : null)
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

                // Filter results by search text
                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return searchText.isEmpty ||
                      (data['name'] as String)
                          .toLowerCase()
                          .contains(searchText.toLowerCase());
                }).toList();

                if (docs.isEmpty) {
                  return Center(child: Text('No results found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    var docId = docs[index].id;
                    int score=int.parse("${data['scrore']}");
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text("name: ${data['name']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Location: ${data['location']}"),
                            Text("Trade: ${data['trade']}"),
                            Text("Score: ${data['scrore']}"),
                            Text("Email: ${data['email']}"),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                score == 0
                                    ? Text(
                                  "Week Perfomance 😡",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                )
                                    : score <= 30
                                    ? Text(
                                  "Need Improve",
                                  style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold),
                                )
                                    : score <= 70
                                    ? Text(
                                  "Average Performance",
                                  style: TextStyle(
                                      color:
                                      Colors.green.shade900),
                                )
                                    : Text(
                                  "Good Performance 🥳",
                                  style: TextStyle(
                                      color:
                                      Colors.green.shade900,
                                      fontWeight:
                                      FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                        leading: data['image'] != null
                            ? Image.network(data['image'])
                            : Icon(Icons.person),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteResult(docId),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

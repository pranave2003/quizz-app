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
          // Search TextField and Dropdowns (remains unchanged)
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
              // Dropdowns (remains unchanged)
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

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("No",style: TextStyle(fontWeight: FontWeight.bold),)), // New Index Column
                      DataColumn(label: Text("Name",style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text("Location",style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text("Trade",style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text("Score",style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text("Performance",style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text("Date",style: TextStyle(fontWeight: FontWeight.bold),)),
                      DataColumn(label: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold),)),
                    ],
                    rows: List<DataRow>.generate(docs.length, (index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      var docId = docs[index].id;
                      int score = int.parse("${data['scrore']}");
                      String performance = score == 0
                          ? "Weak Performance"
                          : score <= 30
                              ? "Need Improve"
                              : score <= 70
                                  ? "Average "
                                  : "Good Performance 🥳";

                      return DataRow(
                        cells: [
                          DataCell(
                              Text((index + 1).toString())), // Display index
                          DataCell(Text(data['name'] ?? '')),
                          DataCell(Text(data['location'] ?? '')),
                          DataCell(Text(data['trade'] ?? '')),
                          DataCell(Text(data['scrore'].toString())),
                          DataCell(
                            Text(
                              performance,
                              style: TextStyle(
                                color: score == 0
                                    ? Colors.red
                                    : score <= 30
                                        ? Colors.amber.shade900
                                        : score <= 70
                                            ? Colors.blueGrey
                                            : Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(data["Assigneddate"])),
                          DataCell(
                            IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.blue.shade50,
                                        title: Text('Delete'),
                                        content: Text(
                                            'Are you sure you want to delete this Rsult?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close the dialog
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteResult(docId);
                                            },
                                            child: Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

var mycolor=Colors.black87;
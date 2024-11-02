import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Model/admin/navigation/mystudentsmodel.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
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
  String searchText = '';
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              )
            : Text(
                'Student List',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.blue.shade100,
        actions: [
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
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  searchText = '';
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Softstudents').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<MyStudents> students = snapshot.data!.docs
              .map((doc) => MyStudents.fromDocumentSnapshot(doc))
              .where((student) {
            bool matchesTrade =
                selectedTrade == 'All' || student.trade == selectedTrade;
            bool matchesLocation = selectedLocation == 'All' ||
                student.officeLocation == selectedLocation;
            bool matchesSearch = searchText.isEmpty ||
                student.name.toLowerCase().contains(searchText);
            return matchesTrade && matchesLocation && matchesSearch;
          }).toList();

          if (students.isEmpty) {
            return Center(child: Text('No students found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'No',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                      label: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Trade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Office Location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'LinkedIn',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'GitHub',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
                rows: List<DataRow>.generate(
                  students.length,
                  (index) {
                    final student = students[index];
                    return DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(
                          student.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(student.email)),
                        DataCell(Text(student.trade)),
                        DataCell(Text(student.officeLocation)),
                        DataCell(
                          TextButton(
                            onPressed: () async {
                              if (student.Linkedin.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("No LinkedIn profile")),
                                );
                              } else {
                                final uri = Uri.parse(student.Linkedin);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Could not launch LinkedIn")),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Open LinkedIn",
                              style: TextStyle(
                                  color: Colors.brown.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          TextButton(
                            onPressed: () async {
                              if (student.Github.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("No GitHub profile")),
                                );
                              } else {
                                final uri = Uri.parse(student.Github);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Could not launch GitHub")),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Open GitHub",
                              style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _confirmDelete(context, student);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MyStudents student) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      FirebaseFirestore.instance
          .collection('Softstudents')
          .doc(student.userId)
          .delete();
    }
  }
}

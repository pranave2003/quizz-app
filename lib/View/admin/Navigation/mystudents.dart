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

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              MyStudents student = students[index];
              return StudentCard(
                student: student,
                index: index,
                onDelete: () async {
                  await _confirmDelete(context, student);
                },
              );
            },
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
          .doc(student.userId) // assuming each student has a unique ID
          .delete();
    }
  }
}

class StudentCard extends StatelessWidget {
  final MyStudents student;
  final int index;
  final VoidCallback onDelete;

  StudentCard({
    required this.student,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(student.imageUrl),
        ),
        title: Text(
          '${index + 1}. ${student.name}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${student.email}'),
            Text('Trade: ${student.trade}'),
            Text('Office Location: ${student.officeLocation}'),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/img.png"),
                ),
                TextButton(
                  onPressed: () async {
                    if (student.Linkedin == '') {
                      print("null data please add");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("didn't Added")),
                      );
                    } else {
                      final uri = Uri.parse(student.Linkedin);
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
                  radius: 10,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/img_1.png"),
                ),
                TextButton(
                  onPressed: () async {
                    if (student.Github == "") {
                      print("null data please add");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("didn't Added")),
                      );
                    } else {
                      final uri = Uri.parse(student.Github);
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
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

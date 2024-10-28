import 'package:cloud_firestore/cloud_firestore.dart';

class MyStudents {
  final String name;
  final String email;
  final String imageUrl;
  final String userId;
  final String trade;
  final String officeLocation;
  final String Linkedin;
  final String Github;

  MyStudents({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.userId,
    required this.trade,
    required this.officeLocation,
    required this.Linkedin,
    required this.Github,
  });

  factory MyStudents.fromDocumentSnapshot(DocumentSnapshot doc) {
    return MyStudents(
        name: doc['name'],
        email: doc['email'],
        imageUrl: doc['imageUrl'],
        userId: doc['userId'],
        trade: doc['Trade'],
        officeLocation: doc['OfficeLocation'],
        Linkedin: doc["Linkdin"],
        Github: doc["github"]);
  }
}

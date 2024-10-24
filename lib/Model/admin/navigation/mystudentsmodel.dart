import 'package:cloud_firestore/cloud_firestore.dart';

class MyStudents {
  final String name;
  final String email;
  final String imageUrl;
  final String userId;
  final String trade;
  final String officeLocation;

  MyStudents({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.userId,
    required this.trade,
    required this.officeLocation,
  });

  factory MyStudents.fromDocumentSnapshot(DocumentSnapshot doc) {
    return MyStudents(
      name: doc['name'],
      email: doc['email'],
      imageUrl: doc['imageUrl'],
      userId: doc['userId'],
      trade: doc['Trade'],
      officeLocation: doc['OfficeLocation'],
    );
  }
}
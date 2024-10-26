import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:quizzapp/View/students/Homescreen.dart';
import 'package:quizzapp/View/students/Resultpage.dart';

import 'Notification.dart';
import 'Profilepage.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    StudentHome(),
    ResultPage(),
    NotificationScreen(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react, // Use TabStyle.fixed, TabStyle.react, etc.
        backgroundColor: Colors.blue.shade900,
        color: Colors.white,
        activeColor: Colors.red,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.star, title: 'Result'),
          TabItem(icon: Icons.message, title: 'Notification'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: _selectedIndex, // Set initial index
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

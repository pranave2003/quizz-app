import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:quizzapp/View/Student20/Fav/Fav.dart';
import 'package:quizzapp/View/Student20/Profilepage.dart';

import 'Homescreen.dart';
import 'Notification.dart';
import 'Resultpage.dart';

class studentCustomBottomNavigationBar extends StatefulWidget {
  @override
  _studentCustomBottomNavigationBarState createState() =>
      _studentCustomBottomNavigationBarState();
}

class _studentCustomBottomNavigationBarState
    extends State<studentCustomBottomNavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    StudentHome20(),
    Result20(),
    NotificationScreen20(),
    ProfilePage20()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react, // Use TabStyle.fixed, TabStyle.react, etc.
        backgroundColor: Colors.white,
        color: mycolor2,
        activeColor: mycolor1,
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

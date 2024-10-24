import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Navigation/Aptitude/shedule_page.dart';
import 'Navigation/Addshedule/Aptitude_Scheduler.dart';
import 'Navigation/mystudents.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0; // Track the selected index

  // List of widgets that corresponds to each tab
  final List<Widget> _pages = [
    StudentListScreen(),
    AptitudePage(),
    Sheadulequastion(),
    LeavesScreen(),
    MyProfileScreen(),
    MyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side Navigation Panel
          NavigationPanel(
            currentIndex: currentIndex, // Pass currentIndex to NavigationPanel
            onTap: (int index) {
              setState(() {
                currentIndex = index; // Update the current index when a button is pressed
              });
            },
          ),
          // Main content area controlled by IndexedStack
          Expanded(
            child: IndexedStack(
              index: currentIndex, // Show content based on the selected index
              children: _pages,    // List of pages that will be switched
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationPanel extends StatelessWidget {
  final ValueChanged<int> onTap; // Function to handle button taps and send index
  final int currentIndex; // To track which button is selected

  NavigationPanel({required this.onTap, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.blue.shade900,
      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              'IQ',
              style: GoogleFonts.abrilFatface(fontSize: 40,color: Colors.white),
            ),
          ),
          NavButton(
            icon: CupertinoIcons.person_2_fill,
            label: 'My Students',
            isSelected: currentIndex == 0, // Check if this button is selected
            onTap: () => onTap(0), // Call onTap with index 0
          ),
          NavButton(
            icon: Icons.book_outlined,
            label: 'Aptitude',
            isSelected: currentIndex == 1, // Check if this button is selected
            onTap: () => onTap(1), // Call onTap with index 1
          ),
          NavButton(
            icon: CupertinoIcons.calendar,
            label: 'Schedule Question',
            isSelected: currentIndex == 2, // Check if this button is selected
            onTap: () => onTap(2), // Call onTap with index 2
          ),
          NavButton(
            icon: Icons.stacked_bar_chart,
            label: 'Result',
            isSelected: currentIndex == 3, // Check if this button is selected
            onTap: () => onTap(3), // Call onTap with index 3
          ),
          NavButton(
            icon: Icons.exit_to_app,
            label: 'Logout',
            isSelected: currentIndex == 4, // Check if this button is selected
            onTap: () => onTap(4), // Call onTap with index 4
          ),
        ],
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected; // Whether this button is selected

  NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected, // Add isSelected parameter
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? Colors.blue : Colors.transparent, // Change color if selected
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.white),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.white, // Change text color if selected
            ),
          ),
        ),
      ),
    );
  }
}

// Screen 1: My Students
class MyStudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is the My Students screen",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Screen 2: Aptitude
class AptitudeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is the Aptitude screen",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Screen 3: My Tasks
class MyTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is the My Tasks screen",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Screen 4: Leaves
class LeavesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is the Leaves screen",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Screen 5: My Profile
class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is the My Profile screen",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

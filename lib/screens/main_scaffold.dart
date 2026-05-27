import 'package:flutter/material.dart';
// 1. Import your real screen files here so this file recognizes them
import 'announcements/announcements_list_screen.dart';
import '../reports/reports_list_screen.dart';
import '../archive/archive_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0; // Tracks the active tab index [cite: 94]

  // 2. Replace the old hardcoded Text placeholders with your actual screen classes 
  final List<Widget> _tabs = [
    const AnnouncementsListScreen(), // Displays your category chips and Hive list [cite: 99, 100]
    const ReportsListScreen(),       // Will display issue reports [cite: 122]
    const ArchiveScreen(),           // Will display soft-deleted items [cite: 142]
  ];

  // Map your tab names to update the AppBar title dynamically [cite: 33, 95]
  final List<String> _titles = [
    'Barangay Announcements',
    'Community Reports',
    'Archived Bulletins',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // Dynamic AppBar title updates automatically [cite: 95]
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // IndexedStack keeps all 3 screens alive in memory so they don't lose scroll state 
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Changes tab view and rebuilds app bar title [cite: 94, 95]
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Gives you ValueListenableBuilder for reactive UI
import 'package:intl/intl.dart';                 // For formatting your dates (e.g., DateFormat)
import '../../models/announcement.dart';         // Import the specific model needed

class AnnouncementDetailScreen extends StatelessWidget {
  // Define the property required by the list view's navigation contract
  final Announcement announcement;

  const AnnouncementDetailScreen({
    super.key, 
    required this.announcement, // It must be required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(announcement.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Detail placeholder for item body:\n\n${announcement.body}'),
        ),
      ),
    );
  }
}
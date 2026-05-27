import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Gives you ValueListenableBuilder for reactive UI
import 'package:intl/intl.dart';                 // For formatting your dates (e.g., DateFormat)
import '../../models/announcement.dart';         // Import the specific model needed

class AnnouncementFormScreen extends StatelessWidget {
  // Make it optional (?) because Create Mode sends a null value
  final Announcement? announcement;

  const AnnouncementFormScreen({
    super.key,
    this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    // Determine whether we are in Create Mode or Edit Mode
    final isEditMode = announcement != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Announcement' : 'New Announcement'),
      ),
      body: Center(
        child: Text(isEditMode 
          ? 'Form Placeholder editing: ${announcement!.title}' 
          : 'Form Placeholder for creating a new item'
        ),
      ),
    );
  }
}
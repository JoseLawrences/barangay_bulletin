import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:barangay_bulletin/models/announcement.dart';
import 'package:barangay_bulletin/screens/announcements/announcement_form_screen.dart'; // ◄ Adjust path if your folder varies slightly

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  // PRD Data Passing Contract: Receives the specific Announcement model instance
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(widget.announcement.datePosted);
    final announcementsBox = Hive.box<Announcement>('announcements');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 1. PIN / UNPIN QUICK ACTION (Milestone 3 Core Goal)
          IconButton(
            icon: Icon(
              widget.announcement.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: widget.announcement.isPinned ? Colors.orange : null,
            ),
            tooltip: widget.announcement.isPinned ? 'Unpin Notice' : 'Pin Notice',
            onPressed: () async {
              // Toggle locally, then overwrite directly to the exact Hive index key
              setState(() {
                widget.announcement.isPinned = !widget.announcement.isPinned;
              });
              await announcementsBox.put(widget.announcement.id, widget.announcement);
              await announcementsBox.flush();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.announcement.isPinned 
                      ? 'Notice pinned to top of bulletin board!' 
                      : 'Notice unpinned.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          // 2. EDIT ACTION (Pencil Icon)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Forward + Return design contract pattern
              final updatedAnnouncement = await Navigator.push<Announcement>(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementFormScreen(announcement: widget.announcement),
                ),
              );

              // If editing returned fresh modifications, persist and refresh layout
              if (updatedAnnouncement != null) {
                await announcementsBox.put(updatedAnnouncement.id, updatedAnnouncement);
                await announcementsBox.flush();
                setState(() {}); // Re-trigger layout tree paint
              }
            },
          ),

          // 3. SOFT-DELETE ACTION (Trash Icon)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Destructive rule verification requirement check
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Move this notice to the archive? It will disappear from active feeds.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );

              // If user confirms the prompt selection, mutate structural fields safely
              if (confirmDelete == true) {
                widget.announcement.isDeleted = true;
                widget.announcement.deletedAt = DateTime.now();

                await announcementsBox.put(widget.announcement.id, widget.announcement);
                await announcementsBox.flush();

                if (mounted) {
                  Navigator.pop(context); // Drop backward into the primary view stack
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Row holding category badge and pinned structural indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Badge Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.announcement.category.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              
              // Sticky Pinned Notice Tag Banner
              if (widget.announcement.isPinned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin, size: 14, color: Colors.orange[800]),
                      const SizedBox(width: 4),
                      Text(
                        'PINNED',
                        style: TextStyle(color: Colors.orange[800], fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary Announcement Headline Header Text
          Text(
            widget.announcement.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),

          // Date Posted Metadata Info Log Entry Line
          Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Posted: $formattedDate',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          // Description Message Label
          const Text(
            'Message Content',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Full Paragraph Description Body Block Box
          Text(
            widget.announcement.body,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
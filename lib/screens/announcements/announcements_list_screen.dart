import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:barangay_bulletin/models/announcement.dart';
import 'package:barangay_bulletin/screens/announcements/announcement_details_screen.dart';
import 'package:barangay_bulletin/screens/announcements/announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  // Store the active category filter state (PRD: All, Info, Event, Emergency, Health)
  String _selectedCategory = 'All'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Category Filter Bar (Horizontal Chips)
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Info', 'Event', 'Emergency', 'Health'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category; // Re-runs layout with new filter
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. The Reactive List View built from Hive
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Announcement>('announcements').listenable(),
              builder: (context, Box<Announcement> box, _) {
                // Get all raw values from Hive
                final allItems = box.values.toList();

                // Apply PRD Filter Rules: Only non-deleted items matching active category
                var filteredItems = allItems.where((item) {
                  final isNotDeleted = !item.isDeleted;
                  final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
                  return isNotDeleted && matchesCategory;
                }).toList();

                // Apply PRD Sorting Rules: Pinned first, then by datePosted descending
                filteredItems.sort((a, b) {
                  if (a.isPinned && !b.isPinned) return -1;
                  if (!a.isPinned && b.isPinned) return 1;
                  return b.datePosted.compareTo(a.datePosted);
                });

                // Handle Empty State
                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'No announcements found matching this category.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // Render the clean ListTiles
                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredItems[index];
                    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(announcement.datePosted);

                    return ListTile(
                      leading: Icon(
                        announcement.isPinned ? Icons.push_pin : Icons.campaign,
                        color: announcement.isPinned ? Colors.orange : Colors.teal,
                      ),
                      title: Text(
                        announcement.title,
                        style: TextStyle(
                          fontWeight: announcement.isPinned ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('$formattedDate\nCategory: ${announcement.category}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Forward Data Passing Contract: Pass item to Detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnouncementDetailScreen(announcement: announcement),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 3. FloatingActionButton to create a new Announcement
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Forward + Return Data Passing Contract: Wait for Form screen result
          final newAnnouncement = await Navigator.push<Announcement>(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementFormScreen(announcement: null), // null = Create Mode
            ),
          );

          // Parent Screen explicitly handles writing to Hive box on successful return
          if (newAnnouncement != null) {
            final box = Hive.box<Announcement>('announcements');
            await box.put(newAnnouncement.id, newAnnouncement);
            // ValueListenableBuilder automatically triggers UI update, no extra setState needed here!
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
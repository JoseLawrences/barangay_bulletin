import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:barangay_bulletin/models/announcement.dart';
import 'package:barangay_bulletin/screens/announcements/announcement_details_screen.dart';
import 'package:barangay_bulletin/screens/announcements/announcement_form_screen.dart';
import 'package:barangay_bulletin/screens/archive/archive_screen.dart';

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
    // FIXED: Correctly returns the Scaffold directly without the stray "body:" label hanging around
    return Scaffold(
      body: Column(
        children: [
          // 1. Category Filter Bar (Horizontal Chips)
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
                // Apply PRD Filter Rules: Convert the enum to a string name before comparing!
                // Apply PRD Filter Rules: Only non-deleted items matching active category
                var filteredItems = allItems.where((item) {
                  final isNotDeleted = !item.isDeleted;
                  
                  // FIXED: Convert the enum object to its string name (e.g. 'info') before comparing with the chip text
                  final matchesCategory = _selectedCategory == 'All' || 
                      item.category.name.toLowerCase() == _selectedCategory.toLowerCase();
                      
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
                      subtitle: Text('$formattedDate\nCategory: ${announcement.category.name.toUpperCase()}'),
                      isThreeLine: true,
                      
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) async {
                          final box = Hive.box<Announcement>('announcements');

                          if (action == 'edit') {
                            final updatedAnnouncement = await Navigator.push<Announcement>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnnouncementFormScreen(announcement: announcement),
                              ),
                            );

                            if (updatedAnnouncement != null) {
                              await box.put(updatedAnnouncement.id, updatedAnnouncement);
                              await box.flush();
                            }
                          } else if (action == 'delete') {
                            // ADDED: PRD Confirmation Dialog before soft-deleting
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to move this announcement to the archive?'),
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

                            // Execute only if user taps 'Delete'
                            if (confirmDelete == true) {
                              setState(() {
                                announcement.isDeleted = true;
                              });
                              await box.put(announcement.id, announcement);
                              await box.flush();
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit, color: Colors.orange),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
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
          final newAnnouncement = await Navigator.push<Announcement>(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementFormScreen(announcement: null),
            ),
          );

          if (newAnnouncement != null) {
            final box = Hive.box<Announcement>('announcements');
            await box.put(newAnnouncement.id, newAnnouncement);
            await box.flush();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
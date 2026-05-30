import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:intl/intl.dart'; 
import 'package:barangay_bulletin/models/announcement.dart'; 

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Notices'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Announcement>('announcements').listenable(),
        builder: (context, Box<Announcement> box, _) {
          final allItems = box.values.toList();

          final archivedItems = allItems.where((item) => item.isDeleted).toList();

          if (archivedItems.isEmpty) {
            return const Center(
              child: Text(
                'Archive is empty...',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: archivedItems.length,
            itemBuilder: (context, index) {
              final announcement = archivedItems[index];
              final formattedDate = DateFormat('MMM dd, yyyy').format(announcement.datePosted);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                color: Colors.grey[200], 
                child: ListTile(
                  leading: const Icon(Icons.archive, color: Colors.grey),
                  title: Text(
                    announcement.title,
                    style: const TextStyle(
                      color: Colors.black, 
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  // FIXED: Added .name.toUpperCase() to match your enum display fixes!
                  subtitle: Text('Posted on: $formattedDate\nCategory: ${announcement.category.name.toUpperCase()}'),
                  isThreeLine: true,
                  
                  // Row layout to place Restore and Hard Delete actions side-by-side
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. RESTORE ACTION (Soft-delete undo)
                      TextButton.icon(
                        icon: const Icon(Icons.unarchive, size: 18, color: Colors.teal),
                        label: const Text('Restore', style: TextStyle(color: Colors.teal)),
                        onPressed: () async {
                          announcement.isDeleted = false;
                          await box.put(announcement.id, announcement);
                          await box.flush();
                        },
                      ),
                      
                      // 2. HARD DELETE ACTION (Permanent Purge)
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        tooltip: 'Permanently Delete',
                        onPressed: () async {
                          // Crucial verification safety dialog check
                          final confirmHardDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Permanently Delete?'),
                                content: const Text('This action cannot be undone. This data will be completely erased from device storage.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Erase Forever', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          // Executed only if confirmed
                          if (confirmHardDelete == true) {
                            // FIXED: Uses box.delete() targeting the unique item id key to purge it completely
                            await box.delete(announcement.id);
                            await box.flush();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ); 
            },
          );
        },
      ),
    );
  }
}
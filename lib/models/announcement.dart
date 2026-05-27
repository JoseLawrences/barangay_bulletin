import 'package:hive/hive.dart';

// Ensure the part file matches your exact filename. 
// If this file is named announcement.dart, this line must be:
part 'announcement.g.dart';

@HiveType(typeId: 0) // Fixed: capitalized 'I' in typeId
enum AnnouncementCategory {
  @HiveField(0)
  info,

  @HiveField(1) // Fixed: capitalized 'F' in HiveField
  event,

  @HiveField(2) // Fixed: capitalized 'F' in HiveField
  emergency,

  @HiveField(3) // Fixed: removed the stray comma
  health,
}

@HiveType(typeId: 1) // Fixed: capitalized 'F' and 'I'
class Announcement extends HiveObject { // Fixed: Cleaned up class name typo
  @HiveField(0) 
  final String id;

  @HiveField(1) // Fixed: capitalized 'F'
  String title;

  @HiveField(2) // Fixed: capitalized 'F'
  String body;

  @HiveField(3) // Fixed: capitalized 'F'
  AnnouncementCategory category;

  @HiveField(4) // Fixed: capitalized 'F'
  final DateTime datePosted;

  @HiveField(5) // Fixed: capitalized 'F'
  bool isPinned;

  @HiveField(6) // Fixed: capitalized 'F'
  bool isDeleted;

  @HiveField(7) // Fixed: capitalized 'F'
  DateTime? deletedAt; // Fixed: Changed from bool to nullable DateTime per PRD

  // Constructor name now matches the class name exactly
  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.datePosted,
    this.isPinned = false,
    this.isDeleted = false,
    this.deletedAt,
  });
}
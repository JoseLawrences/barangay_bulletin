import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/announcement.dart';  // Import your announcement model
import 'models/issue_report.dart';  // Import your issue report model
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // 1. REGISTER THE GENERATED ADAPTERS (Crucial for Milestone 1!)
  Hive.registerAdapter(AnnouncementCategoryAdapter()); // Generated from enum
  Hive.registerAdapter(AnnouncementAdapter());         // Generated from class
  Hive.registerAdapter(IssueReportCategoryAdapter());  // Generated from enum
  Hive.registerAdapter(IssueReportStatusAdapter());    // Generated from enum
  Hive.registerAdapter(IssueReportAdapter());          // Generated from class

  // 2. OPEN THE BOXES EAGERLY
  await Hive.openBox<Announcement>('announcements');
  await Hive.openBox<IssueReport>('issue_reports');

  runApp(const BarangayBulletinApp());
}

class BarangayBulletinApp extends StatelessWidget {
  const BarangayBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MainScaffold(), 
    );
  }
}
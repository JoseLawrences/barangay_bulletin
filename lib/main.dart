import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/announcement.dart';  // Uncomment after generating adapters
import 'models/issue_report.dart';  // Uncomment after generating adapters
import 'screens/main_scaffold.dart';

void main() async {
  // 1. Ensure Flutter framework bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive database for Flutter
  await Hive.initFlutter();

  // 3. Register generated TypeAdapters (Uncomment these once .g.dart files exist)
  // Hive.registerAdapter(AnnouncementAdapter()); [cite: 73]
  // Hive.registerAdapter(IssueReportAdapter()); [cite: 73]

  // 4. Open the local Hive boxes eagerly before the UI boots up
  // await Hive.openBox<Announcement>('announcements'); [cite: 74, 75]
  // await Hive.openBox<IssueReport>('issue_reports'); [cite: 74, 76]

  runApp(const BarangayBulletinApp());
}

class BarangayBulletinApp extends StatelessWidget {
  const BarangayBulletinApp({super.key});

  @override
  Widget build(BuildContext MaterialContext) {
    return MaterialApp(
      title: 'Barangay Bulletin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Define your custom color scheme here to satisfy the UI/UX rubric
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, // Example primary color scheme
        ),
      ),
      // MainScaffold will handle your BottomNavigationBar and persistent tab state
      home: const MainScaffold(), 
    );
  }
}
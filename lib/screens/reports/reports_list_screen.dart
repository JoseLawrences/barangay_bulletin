import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Gives you ValueListenableBuilder for reactive UI
import 'package:intl/intl.dart';                 // For formatting your dates (e.g., DateFormat)
import '../../models/announcement.dart';         // Import the specific model needed

import 'package:flutter/material.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Reports List Screen Content Will Go Here'));
  }
}
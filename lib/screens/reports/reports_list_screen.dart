import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:barangay_bulletin/models/issue_report.dart';
import 'package:barangay_bulletin/screens/reports/report_form_screen.dart';
import 'package:barangay_bulletin/screens/reports/report_detail_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  String _selectedStatus = 'All'; // Filter state: All, Pending, In Progress, Resolved

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. Status Filter Bar (ChoiceChips)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Pending', 'In Progress', 'Resolved'].map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. Reactive Hive Box Builder
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<IssueReport>('issue_reports').listenable(),
              builder: (context, Box<IssueReport> box, _) {
                final allItems = box.values.toList();

                // Filter out soft-deleted items and match active status selection
                var filteredItems = allItems.where((item) {
                  final isNotDeleted = !item.isDeleted;
                  final matchesStatus = _selectedStatus == 'All' || item.status == _selectedStatus;
                  return isNotDeleted && matchesStatus;
                }).toList();

                // Sort: Newest reports appear at the top
                filteredItems.sort((a, b) => b.dateReported.compareTo(a.dateReported));

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reports found matching this status.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final report = filteredItems[index];
                    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(report.dateReported);

                    return ListTile(
                      leading: const Icon(Icons.report_problem, color: Colors.redAccent),
                      title: Text(report.title),
                      subtitle: Text('$formattedDate\nStatus: ${report.status.name.toUpperCase()}'),
                      isThreeLine: true,
                      
                      // 3-Dot Options Action Menu
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) async {
                          final reportsBox = Hive.box<IssueReport>('issue_reports');

                          if (action == 'edit') {
                            // Forward Data Contract: Pass report to form screen for editing
                            final updatedReport = await Navigator.push<IssueReport>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportFormScreen(report: report),
                              ),
                            );

                            if (updatedReport != null) {
                              await reportsBox.put(updatedReport.id, updatedReport);
                              await reportsBox.flush();
                            }
                          } else if (action == 'delete') {
                            // Milestone 2 Requirement: Show confirmation box before soft-delete
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to move this issue report to the archive?'),
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

                            if (confirmDelete == true) {
                              setState(() {
                                report.isDeleted = true; // Mark as soft-deleted
                              });
                              await reportsBox.put(report.id, report);
                              await reportsBox.flush();
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
                        // View Details Action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailScreen(report: report),
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

      // FloatingActionButton for creating a new item
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newReport = await Navigator.push<IssueReport>(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportFormScreen(report: null), // null = Create Mode
            ),
          );

          if (newReport != null) {
            final reportsBox = Hive.box<IssueReport>('issue_reports');
            await reportsBox.put(newReport.id, newReport);
            await reportsBox.flush();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
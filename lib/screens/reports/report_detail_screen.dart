import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:barangay_bulletin/models/issue_report.dart';
import 'package:barangay_bulletin/screens/reports/report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final IssueReport report;

  // PRD Forward Data Contract: Receives the IssueReport object via constructor
  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // Color codes required by PRD Section 4.5
  Color _getStatusColor(IssueReportStatus status) {
    switch (status) {
      case IssueReportStatus.pending:
        return Colors.orange;
      case IssueReportStatus.inProgress:
        return Colors.blue;
      case IssueReportStatus.resolved:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(widget.report.dateReported);
    final reportsBox = Hive.box<IssueReport>('issue_reports');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 1. EDIT ACTION (Pencil Icon)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Forward + Return contract pattern
              final updatedReport = await Navigator.push<IssueReport>(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportFormScreen(report: widget.report),
                ),
              );

              // If data was returned, persist to Hive and update screen state
              if (updatedReport != null) {
                await reportsBox.put(updatedReport.id, updatedReport);
                await reportsBox.flush();
                setState(() {}); // Refresh local UI elements
              }
            },
          ),

          // 2. SOFT-DELETE ACTION (Trash Icon)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Mandatory PRD destructive confirmation dialog box rule
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to archive this issue report?'),
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

              // If user confirms, apply soft-delete timestamps and save
              if (confirmDelete == true) {
                widget.report.isDeleted = true;
                widget.report.deletedAt = DateTime.now();

                await reportsBox.put(widget.report.id, widget.report);
                await reportsBox.flush();

                if (mounted) {
                  Navigator.pop(context); // Pop back to the primary list screen
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Status Badge Display Element
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.report.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.report.status.name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title Display Element
          Text(
            widget.report.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Metadata Info Row (Category & Date)
          Row(
            children: [
              Icon(Icons.label, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Category: ${widget.report.category.name.toUpperCase()}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Reported: $formattedDate',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          // 3. INLINE STATUS UPDATE SHORTCUT (Milestone 3 Goal Requirement)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Update Status:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<IssueReportStatus>(
                    value: widget.report.status,
                    underline: Container(), // Removes ugly default underline
                    items: IssueReportStatus.values.map((statusOption) {
                      return DropdownMenuItem(
                        value: statusOption,
                        child: Text(statusOption.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (newStatus) async {
                      if (newStatus != null) {
                        // Mutate model status directly and save immediately to Hive
                        setState(() {
                          widget.report.status = newStatus;
                        });
                        await reportsBox.put(widget.report.id, widget.report);
                        await reportsBox.flush();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Description Body Text Heading
          const Text(
            'Description Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Full Description Text Container Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              widget.report.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
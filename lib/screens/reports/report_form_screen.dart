import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; 
import 'package:barangay_bulletin/models/issue_report.dart'; 

class ReportFormScreen extends StatefulWidget {
  final IssueReport? report;

  const ReportFormScreen({
    super.key,
    this.report,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  // FIXED: Track states using your explicit Enum types instead of raw Strings
  late IssueReportCategory _selectedCategory; 
  late IssueReportStatus _selectedStatus; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report?.title ?? '');
    _descriptionController = TextEditingController(text: widget.report?.description ?? '');
    
    // FIXED: Initialize using your Model's enum values directly
    if (widget.report != null) {
      _selectedCategory = widget.report!.category;
      _selectedStatus = widget.report!.status;
    } else {
      // Default initial states for Create Mode
      // (Adjust 'road' or 'pending' to match your exact enum element case naming if needed)
      _selectedCategory = IssueReportCategory.road; 
      _selectedStatus = IssueReportStatus.pending; 
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.report == null) {
      // --- CREATE MODE ---
      final newReport = IssueReport(
        id: const Uuid().v4(), 
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory, // FIXED: Now passes correct IssueReportCategory type
        status: _selectedStatus,     // FIXED: Now passes correct IssueReportStatus type
        dateReported: DateTime.now(), 
        isDeleted: false,
      );

      Navigator.pop(context, newReport);
    } else {
      // --- EDIT MODE ---
      widget.report!.title = _titleController.text.trim();
      widget.report!.description = _descriptionController.text.trim();
      widget.report!.category = _selectedCategory; // FIXED: Type match assignment
      widget.report!.status = _selectedStatus;     // FIXED: Type match assignment

      Navigator.pop(context, widget.report);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.report != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Issue Report' : 'File New Report'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. Issue Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Issue Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // 2. FIXED: Category Dropdown mapped directly over IssueReportCategory enum options
              DropdownButtonFormField<IssueReportCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: IssueReportCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    // .name converts the enum value to a readable string cleanly
                    child: Text(cat.name.toUpperCase()), 
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3. FIXED: Status Dropdown mapped directly over IssueReportStatus enum options
              DropdownButtonFormField<IssueReportStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: IssueReportStatus.values.map((stat) {
                  return DropdownMenuItem(
                    value: stat,
                    child: Text(stat.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedStatus = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 4. Detailed Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description Details',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description details' : null,
              ),
              const SizedBox(height: 24),

              // 5. Submit Action Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isEditMode ? 'Save Changes' : 'Submit Report',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Gives you ValueListenableBuilder for reactive UI
import 'package:intl/intl.dart';                 // For formatting your dates (e.g., DateFormat)
import '../../models/announcement.dart';         // Import the specific model needed
import 'package:uuid/uuid.dart'; // unique id strings

class AnnouncementFormScreen extends StatefulWidget {
  // Make it optional (?) because Create Mode sends a null value
  final Announcement? announcement;

  const AnnouncementFormScreen({
    super.key,
    this.announcement,
  });

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen>{
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late AnnouncementCategory _selectedCategory;
  late bool _isPinned;

  @override
  void initState(){
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _bodyController = TextEditingController(text: widget.announcement?.body ?? '');
    _selectedCategory = widget.announcement?.category ?? AnnouncementCategory.info;
    _isPinned = widget.announcement?.isPinned ?? false;
  }

  @override
  void dispose(){
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void _submitForm(){
    if(!_formKey.currentState!.validate()) return;

    if(widget.announcement == null){
      final newAnnouncement = Announcement(
        id: const Uuid().v4(), //generates unique v4 string
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        category: _selectedCategory,
        datePosted: DateTime.now(),
        isPinned: _isPinned,
      );

      Navigator.pop(context, newAnnouncement);
    }else{
      widget.announcement!.title = _titleController.text.trim();
      widget.announcement!.body = _bodyController.text.trim();
      widget.announcement!.category = _selectedCategory;
      widget.announcement!.isPinned = _isPinned;

      Navigator.pop(context, widget.announcement);
    }
  }

  @override
  Widget build(BuildContext context){
    final isEditMode = widget.announcement != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Announcement' : 'New Announcement'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children:[

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Announcement Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<AnnouncementCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: AnnouncementCategory.values.map((cat){
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val){
                  if(val != null){
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Details / Body Message',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter message details' : null,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Pin to top of bulletin board'),
                subtitle: const Text('Pinned items always jump ahead of regular notices.'),
                value: _isPinned,
                activeColor: Colors.orange,
                onChanged: (val){
                  setState(() => _isPinned = val);
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isEditMode ? 'Save Changes' : 'Post Announcement',
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
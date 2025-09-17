import 'package:flutter/material.dart';
import '../models/notes_model.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note note;
  final Function(String) onDelete;
  final Function(Note) onEdit;

  const NoteDetailsScreen({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _NoteDetailsScreenState createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  final editTitleController = TextEditingController();
  final contentController = TextEditingController();

  void deleteNote() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Note', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.delete, size: 18),
              label: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onDelete(widget.note.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop('deleted');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note deleted'), backgroundColor: Colors.red),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void editNote() {
    editTitleController.text = widget.note.title;
    contentController.text = widget.note.content;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Note', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editTitleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Content",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.check, size: 18),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onEdit(
                  Note(
                    id: widget.note.id,
                    title: editTitleController.text,
                    content: contentController.text,
                    createdAt: widget.note.createdAt,
                  ),
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop('updated');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note updated successfully'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDetailedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.note.title.isEmpty ? 'Untitled' : widget.note.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Created: ${_formatDetailedDate(widget.note.createdAt)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.note.content.isEmpty ? 'No content' : widget.note.content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: widget.note.content.isEmpty
                      ? Colors.grey
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: editNote,
                icon: Icon(Icons.edit, color: Colors.white),
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Edit Note',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:redx_notes_app/screens/add_note_screen.dart';
import 'package:redx_notes_app/screens/notes_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notes_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  late SharedPreferences prefs;
  String searchQuery = "";
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    prefs = await SharedPreferences.getInstance();
    List<String> notesList = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = notesList.map((noteString) {
        Map<String, dynamic> noteMap = json.decode(noteString);
        return Note.fromJson(noteMap);
      }).toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      filteredNotes = notes;
    });
  }

  Future<void> saveNotes() async {
    List<String> notesList = notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList('notes', notesList);
  }

  void deleteNote(String noteId) {
    setState(() {
      notes.removeWhere((note) => note.id == noteId);
      filteredNotes = _filterNotes(searchQuery);
    });
    saveNotes();
  }

  void editNote(Note updatedNote) {
    setState(() {
      int index = notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        notes[index] = updatedNote;
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filteredNotes = _filterNotes(searchQuery);
      }
    });
    saveNotes();
  }

  List<Note> _filterNotes(String query) {
    if (query.isEmpty) return notes;
    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
      final contentMatch = note.content.toLowerCase().contains(query.toLowerCase());
      return titleMatch || contentMatch;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? const Text('My Notes ')
            : TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              filteredNotes = _filterNotes(searchQuery);
            });
          },
        ),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search,color: Colors.blue,),
              onPressed: () {
                setState(() => isSearching = true);
              },
            )

          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = "";
                  searchController.clear();
                  filteredNotes = notes;
                });
              },
            ),  SizedBox(width: 11,),

        ],
      ),
      body: filteredNotes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined,
                size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No notes yet' : 'No matching notes',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(note.createdAt),
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailsScreen(
                      note: note,
                      onDelete: deleteNote,
                      onEdit: editNote,
                    ),
                  ),
                );
                if (result == 'deleted' || result == 'updated') {
                  loadNotes();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          if (result != null) {
            setState(() {
              notes.add(result);
              notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              filteredNotes = _filterNotes(searchQuery);
            });
            saveNotes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}

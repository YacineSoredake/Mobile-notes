import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth/auth_service.dart';
import 'package:flutter_app/services/crud/note_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _noteService = NoteService();
    _textController = TextEditingController();
    _setupTextController();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _noteService.updateNote(note: note, text: text);
  }

  void _setupTextController() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote?> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) return existingNote;

    final currentUser = AuthService.firebase().currentUser;
    if (currentUser == null) return null;

    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    final newNote = await _noteService.createNote(owner: owner, text: '');
    setState(() {
      _note = newNote;
    });
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    final text = _textController.text;
    if (text.isEmpty && note != null) {
      _noteService.deleteNote(id: note.id);
    }
  }

  Future<void> _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder<DatabaseNote?>(
        future: createNewNote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to create note.'));
          } else {
            // Only assign _note if it's not already set
            if (_note == null) {
              _note = snapshot.data;
              _setupTextController();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type your note here...',
                  border: OutlineInputBorder(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

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

  void initState() {
    super.initState();
    _noteService = NoteService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _noteService.updateNote(note: note, text: text);
  }

  void _setupTextController() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final text = _textController.text;
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    return await _noteService.createNote(owner: owner, text: text);
  }

  void _DeleteNoteIfEmpty() {
    final note = _note;
    final text = _textController.text;
    if (text.isEmpty && note != null) {
      _noteService.deleteNote(id: note.id);
    }
  }

  void _SaveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _DeleteNoteIfEmpty();
    _SaveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final note = await createNewNote();
              _note = note;
              _setupTextController();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextController();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Type your note here...',
                ),
                maxLines: null,
              );
            default:
              return const Center(child: Text('Unexpected state'));
          }
        },
      ) ,
    );
  }
}

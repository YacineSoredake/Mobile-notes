import 'package:flutter/material.dart';
import 'package:flutter_app/services/crud/note_service.dart';
import 'package:flutter_app/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Text(
              note.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
           trailing: IconButton(onPressed: ()async{
            final shouldBeDeleted = await showDeletetDialog(context);
            if (shouldBeDeleted) {
              onDeleteNote(note);
            }
           }, icon: const Icon(Icons.delete)),
          ),
        );
      },
    );
  }
  
  Future showDeleteDialog(BuildContext context) async {}
}

import 'package:flutter/material.dart';
import 'package:flutter_app/constants/routes.dart';
import 'package:flutter_app/services/auth/auth_service.dart';
import 'package:flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_app/services/auth/bloc/auth_event.dart';
import 'package:flutter_app/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_app/utilities/dialogs/logout_diaglog.dart';
import 'package:flutter_app/views/notes/notes_list_view.dart';
import 'package:flutter_app/services/cloud/cloud_note.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction { logout }

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('📝 My Notes'),
        backgroundColor: const Color(0xFF076D38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Add new note',
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(NoteRoute);
            },
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _noteService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as Iterable).isEmpty) {
            return const Center(
              child: Text(
                '📭 No notes yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final allNotes = snapshot.data as Iterable<CloudNote>;
          return NotesListView(
            notes: allNotes.toList(), // ✅ convert to List
            onDeleteNote: (note) async {
              await _noteService.DeleteNote(documentId: note.documentId);
            },
            onTapNote: (note) {
              Navigator.of(context).pushNamed(NoteRoute, arguments: note);
            },
          );
        },
      ),
    );
  }
}

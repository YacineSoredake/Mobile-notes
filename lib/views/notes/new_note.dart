import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Logic to save the note
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}
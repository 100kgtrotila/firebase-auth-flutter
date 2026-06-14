import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:firebase_auth_flutter/features/notes/providers/notes_provider.dart';
import 'package:firebase_auth_flutter/features/notes/screens/note_form_screen.dart';
import 'package:firebase_auth_flutter/features/notes/widgets/empty_notes_view.dart';
import 'package:firebase_auth_flutter/features/notes/widgets/note_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  void _openCreateNote(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NoteFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final notesStream = context.read<NotesProvider>().notesStream;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 My Notes'),
        actions: [
          IconButton(
            tooltip: 'Create note',
            onPressed: () => _openCreateNote(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Note>>(
          stream: notesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Failed to load notes. Please try again later.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final notes = snapshot.data ?? [];

            if (notes.isEmpty) {
              return const EmptyNotesView();
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteCard(note: notes[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

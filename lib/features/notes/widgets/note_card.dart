import 'package:firebase_auth_flutter/core/utils/date_formatter.dart';
import 'package:firebase_auth_flutter/core/utils/snack_bar_helper.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:firebase_auth_flutter/features/notes/providers/notes_provider.dart';
import 'package:firebase_auth_flutter/features/notes/screens/note_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({required this.note, super.key});

  final Note note;

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete note'),
          content: const Text(
            'Are you sure you want to delete this note? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(96, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    final error = await context.read<NotesProvider>().deleteNote(note.id);

    if (!context.mounted) {
      return;
    }

    if (error != null) {
      SnackBarHelper.showMessage(context, error);
      return;
    }

    SnackBarHelper.showMessage(context, 'Note deleted successfully');
  }

  void _openEditNote(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)));
  }

  String get _dateLabel {
    final wasUpdated = note.updatedAt.difference(note.createdAt).inSeconds > 1;
    final date = wasUpdated ? note.updatedAt : note.createdAt;
    final prefix = wasUpdated ? 'Updated' : 'Created';

    return '$prefix ${DateFormatter.formatDateTime(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<NotesProvider>().isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📌', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit note',
                  onPressed: isLoading ? null : () => _openEditNote(context),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete note',
                  onPressed: isLoading ? null : () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _dateLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

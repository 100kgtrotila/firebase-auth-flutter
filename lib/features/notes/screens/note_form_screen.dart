import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:firebase_auth_flutter/core/utils/snack_bar_helper.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:firebase_auth_flutter/features/notes/providers/notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final notesProvider = context.read<NotesProvider>();
    final error = _isEditing
        ? await notesProvider.updateNote(
            noteId: widget.note!.id,
            title: _titleController.text,
            content: _contentController.text,
          )
        : await notesProvider.createNote(
            title: _titleController.text,
            content: _contentController.text,
          );

    if (!mounted) {
      return;
    }

    if (error != null) {
      SnackBarHelper.showMessage(context, error);
      return;
    }

    SnackBarHelper.showMessage(
      context,
      _isEditing ? 'Note updated successfully' : 'Note created successfully',
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<NotesProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Note' : 'Create Note')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  validator: Validators.validateNoteTitle,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  minLines: 5,
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  validator: Validators.validateNoteContent,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write something...',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'SAVE CHANGES' : 'CREATE NOTE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

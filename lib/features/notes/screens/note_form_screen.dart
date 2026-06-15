import 'dart:typed_data';

import 'package:firebase_auth_flutter/core/utils/snack_bar_helper.dart';
import 'package:firebase_auth_flutter/core/utils/validators.dart';
import 'package:firebase_auth_flutter/features/notes/models/note.dart';
import 'package:firebase_auth_flutter/features/notes/providers/notes_provider.dart';
import 'package:firebase_auth_flutter/features/notes/widgets/note_image_picker_section.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _removeCurrentImage = false;

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

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedImage == null) {
      return;
    }

    final imageSize = await pickedImage.length();
    final imageBytes = await pickedImage.readAsBytes();

    if (!mounted) {
      return;
    }

    if (imageSize > NotesProvider.maxImageSizeBytes) {
      SnackBarHelper.showMessage(
        context,
        'Image is too large. Maximum size is 5MB.',
      );
      return;
    }

    setState(() {
      _selectedImageFile = pickedImage;
      _selectedImageBytes = imageBytes;
      _removeCurrentImage = false;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageBytes = null;
      _removeCurrentImage = widget.note?.imageUrl != null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final notesProvider = context.read<NotesProvider>();
    final error = _isEditing
        ? await notesProvider.updateNote(
            note: widget.note!,
            title: _titleController.text,
            content: _contentController.text,
            newImageFile: _selectedImageFile,
            removeCurrentImage: _removeCurrentImage,
          )
        : await notesProvider.createNote(
            title: _titleController.text,
            content: _contentController.text,
            imageFile: _selectedImageFile,
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
    final notesProvider = context.watch<NotesProvider>();
    final isLoading = notesProvider.isLoading;
    final isUploading = isLoading && _selectedImageFile != null;

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
                NoteImagePickerSection(
                  selectedImageBytes: _selectedImageBytes,
                  imageUrl: widget.note?.imageUrl,
                  removeCurrentImage: _removeCurrentImage,
                  isUploading: isUploading,
                  uploadProgress: notesProvider.uploadProgress,
                  onPickImage: _pickImage,
                  onRemoveImage: _removeImage,
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

import 'dart:typed_data';

import 'package:flutter/material.dart';

class NoteImagePickerSection extends StatelessWidget {
  const NoteImagePickerSection({
    required this.selectedImageBytes,
    required this.imageUrl,
    required this.removeCurrentImage,
    required this.isUploading,
    required this.uploadProgress,
    required this.onPickImage,
    required this.onRemoveImage,
    super.key,
  });

  final Uint8List? selectedImageBytes;
  final String? imageUrl;
  final bool removeCurrentImage;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  bool get _hasExistingImage {
    return imageUrl != null && imageUrl!.isNotEmpty && !removeCurrentImage;
  }

  bool get _hasImage {
    return selectedImageBytes != null || _hasExistingImage;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = uploadProgress.clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Attachment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ImagePreview(
              selectedImageBytes: selectedImageBytes,
              imageUrl: imageUrl,
              removeCurrentImage: removeCurrentImage,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isUploading ? null : onPickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(_hasImage ? 'Change Photo' : 'Add Photo'),
                ),
                if (_hasImage)
                  TextButton.icon(
                    onPressed: isUploading ? null : onRemoveImage,
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    label: Text(
                      'Remove Photo',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
              ],
            ),
            if (isUploading && progress > 0) ...[
              const SizedBox(height: 14),
              Text('Uploading... ${(progress * 100).round()}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.selectedImageBytes,
    required this.imageUrl,
    required this.removeCurrentImage,
  });

  final Uint8List? selectedImageBytes;
  final String? imageUrl;
  final bool removeCurrentImage;

  bool get _hasExistingImage {
    return imageUrl != null && imageUrl!.isNotEmpty && !removeCurrentImage;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewHeight = constraints.maxWidth > 520 ? 320.0 : 240.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: previewHeight,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            alignment: Alignment.center,
            child: _buildImage(context),
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (selectedImageBytes != null) {
      return Image.memory(
        selectedImageBytes!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    if (_hasExistingImage) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(colorScheme: colorScheme, text: 'Image failed');
        },
      );
    }

    return _Placeholder(colorScheme: colorScheme, text: 'No image selected');
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colorScheme, required this.text});

  final ColorScheme colorScheme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_outlined,
          size: 42,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

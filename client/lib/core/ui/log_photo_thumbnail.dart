import 'dart:io';

import 'package:flutter/material.dart';

import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/theme/app_radius.dart';

class LogPhotoThumbnail extends StatelessWidget {
  const LogPhotoThumbnail({
    super.key,
    required this.photoPath,
    this.size = 48,
    this.onTap,
  });

  final String? photoPath;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final storage = AppServicesScope.of(context).logPhotoStorage;

    return FutureBuilder<File?>(
      future: storage.getFile(photoPath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return SizedBox(
            width: size,
            height: size,
            child: const Icon(Icons.broken_image_outlined),
          );
        }

        final image = ClipRRect(
          borderRadius: AppRadius.borderSm,
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );

        if (onTap == null) return image;
        return InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderSm,
          child: image,
        );
      },
    );
  }
}

class LogPhotoPreviewDialog extends StatelessWidget {
  const LogPhotoPreviewDialog({super.key, required this.photoPath});

  final String photoPath;

  static Future<void> show(BuildContext context, String photoPath) {
    return showDialog<void>(
      context: context,
      builder: (_) => LogPhotoPreviewDialog(photoPath: photoPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LogPhotoThumbnail(photoPath: photoPath, size: 280),
      ),
    );
  }
}

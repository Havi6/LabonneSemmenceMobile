import 'dart:io';
import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/services/download_service.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';

class SmartImage extends StatelessWidget {
  final String? id;
  final String remoteUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? heroTag;
  final bool isGallery;

  const SmartImage({
    super.key,
    this.id,
    required this.remoteUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.heroTag,
    this.isGallery = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DownloadService.instance,
      builder: (context, _) {
        final localPath = isGallery 
            ? DownloadService.instance.getLocalGalleryImage(id)
            : DownloadService.instance.getLocalSermonImage(id);

        Widget imageWidget;
        
        if (localPath != null && File(localPath).existsSync()) {
          imageWidget = Image.file(
            File(localPath),
            fit: fit,
            width: width,
            height: height,
          );
        } else if (remoteUrl.isNotEmpty) {
          imageWidget = Image.network(
            remoteUrl,
            fit: fit,
            width: width,
            height: height,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceLight
                    : Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        } else {
          imageWidget = _buildFallback();
        }

        if (heroTag != null) {
          return Hero(tag: heroTag!, child: imageWidget);
        }
        return imageWidget;
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.church_outlined,
        size: (height ?? 100) * 0.5,
        color: AppColors.primary,
      ),
    );
  }
}

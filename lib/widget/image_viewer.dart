import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/models/entities.dart';
import 'package:la_bonne_semence_mobile/services/download_service.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';

class ImageViewer extends StatelessWidget {
  final GalleryItem item;

  const ImageViewer({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(item.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: DownloadService.instance,
            builder: (context, _) {
              final isDownloaded = DownloadService.instance.isDownloaded(item.id);
              final progress = DownloadService.instance.getProgress(item.id ?? '');

              if (progress > 0 && progress < 1) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }

              return IconButton(
                icon: Icon(
                  isDownloaded ? Icons.download_done : Icons.download,
                  color: isDownloaded ? Colors.green : Colors.white,
                ),
                onPressed: isDownloaded
                    ? null
                    : () async {
                        try {
                          await DownloadService.instance.downloadGalleryItem(item);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Photo téléchargée"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Erreur lors du téléchargement"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: item.url,
            child: Image.network(
              item.url,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/services/download_service.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/pages/sermon_player_page.dart';
import 'package:la_bonne_semence_mobile/widget/image_viewer.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mes téléchargements"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.audio_file), text: "Sermons"),
              Tab(icon: Icon(Icons.image), text: "Photos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SermonDownloads(),
            _GalleryDownloads(),
          ],
        ),
      ),
    );
  }
}

class _SermonDownloads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DownloadService.instance,
      builder: (context, _) {
        final sermons = DownloadService.instance.downloadedSermons;

        if (sermons.isEmpty) {
          return const _EmptyDownloads(message: "Aucun sermon téléchargé");
        }

        return ListView.builder(
          itemCount: sermons.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final sermon = sermons[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildLeading(sermon.imageUrl),
                ),
                title: Text(
                  sermon.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(sermon.author),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, sermon.id!, sermon.title),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SermonPlayerPage(sermon: sermon),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _GalleryDownloads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DownloadService.instance,
      builder: (context, _) {
        final items = DownloadService.instance.downloadedGallery;

        if (items.isEmpty) {
          return const _EmptyDownloads(message: "Aucune photo téléchargée");
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildLeading(item.url),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _confirmDelete(context, item.id!, item.title),
                            child: const Icon(Icons.delete,
                                color: Colors.red, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewer(item: item),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyDownloads extends StatelessWidget {
  final String message;
  const _EmptyDownloads({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download_for_offline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

Widget _buildLeading(String path) {
  if (path.isNotEmpty) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
  }
  return Container(
    color: AppColors.primary.withValues(alpha: 0.1),
    child: const Icon(Icons.image, color: AppColors.primary),
  );
}

void _confirmDelete(BuildContext context, String id, String title) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Supprimer le téléchargement"),
      content: Text("Voulez-vous supprimer '$title' ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () {
            DownloadService.instance.deleteDownload(id);
            Navigator.pop(context);
          },
          child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

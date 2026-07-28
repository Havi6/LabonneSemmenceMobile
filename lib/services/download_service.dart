import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:la_bonne_semence_mobile/models/entities.dart';

class DownloadService extends ChangeNotifier {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  final Dio _dio = Dio();
  final Map<String, double> _progressMap = {};
  List<Sermon> _downloadedSermons = [];
  List<GalleryItem> _downloadedGallery = [];
  bool _isInitialized = false;

  List<Sermon> get downloadedSermons => _downloadedSermons;
  List<GalleryItem> get downloadedGallery => _downloadedGallery;

  double getProgress(String id) => _progressMap[id] ?? 0.0;

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadMetadata();
    _isInitialized = true;
  }

  Future<void> downloadSermon(Sermon sermon) async {
    if (sermon.id == null) return;
    final id = sermon.id!;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(dir.path, 'downloads', 'sermons', id));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      // Download Audio
      final audioPath = p.join(folder.path, 'audio.mp3');
      await _dio.download(
        sermon.audioUrl,
        audioPath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            _progressMap[id] = count / total;
            notifyListeners();
          }
        },
      );

      // Download Image if exists
      String localImagePath = '';
      if (sermon.imageUrl.isNotEmpty) {
        localImagePath = p.join(folder.path, 'image.jpg');
        try {
          await _dio.download(sermon.imageUrl, localImagePath);
        } catch (e) {
          debugPrint('Failed to download image: $e');
        }
      }

      // Create local sermon object
      final localSermon = Sermon(
        id: id,
        title: sermon.title,
        description: sermon.description,
        author: sermon.author,
        duration: sermon.duration,
        date: sermon.date,
        verse: sermon.verse,
        audioUrl: audioPath, // Path to local file
        imageUrl: localImagePath, // Path to local file
        imageCaption: sermon.imageCaption,
      );

      _downloadedSermons.removeWhere((s) => s.id == id);
      _downloadedSermons.add(localSermon);
      await _saveMetadata();
      
      _progressMap.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Download error: $e');
      _progressMap.remove(id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> downloadGalleryItem(GalleryItem item) async {
    if (item.id == null) return;
    final id = item.id!;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(dir.path, 'downloads', 'gallery', id));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final localPath = p.join(folder.path, 'image.jpg');
      await _dio.download(
        item.url,
        localPath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            _progressMap[id] = count / total;
            notifyListeners();
          }
        },
      );

      final localItem = GalleryItem(
        id: id,
        url: localPath,
        title: item.title,
      );

      _downloadedGallery.removeWhere((i) => i.id == id);
      _downloadedGallery.add(localItem);
      await _saveMetadata();

      _progressMap.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Gallery download error: $e');
      _progressMap.remove(id);
      notifyListeners();
      rethrow;
    }
  }

  bool isDownloaded(String? id) {
    if (id == null) return false;
    return _downloadedSermons.any((s) => s.id == id) || 
           _downloadedGallery.any((i) => i.id == id);
  }

  Future<void> deleteDownload(String id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      
      // Try sermon
      final sermonFolder = Directory(p.join(dir.path, 'downloads', 'sermons', id));
      if (await sermonFolder.exists()) {
        await sermonFolder.delete(recursive: true);
      }
      _downloadedSermons.removeWhere((s) => s.id == id);

      // Try gallery
      final galleryFolder = Directory(p.join(dir.path, 'downloads', 'gallery', id));
      if (await galleryFolder.exists()) {
        await galleryFolder.delete(recursive: true);
      }
      _downloadedGallery.removeWhere((i) => i.id == id);

      await _saveMetadata();
      notifyListeners();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> _loadMetadata() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'downloads', 'metadata.json'));
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> metadata = jsonDecode(content);
        
        if (metadata.containsKey('sermons')) {
          _downloadedSermons = (metadata['sermons'] as List)
              .map((j) => Sermon.fromJson(j))
              .toList();
        }
        if (metadata.containsKey('gallery')) {
          _downloadedGallery = (metadata['gallery'] as List)
              .map((j) => GalleryItem.fromJson(j))
              .toList();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load metadata error: $e');
    }
  }

  Future<void> _saveMetadata() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(p.join(dir.path, 'downloads'));
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final file = File(p.join(downloadsDir.path, 'metadata.json'));
      final metadata = {
        'sermons': _downloadedSermons.map((s) => s.toJson()).toList(),
        'gallery': _downloadedGallery.map((i) => i.toJson()).toList(),
      };
      await file.writeAsString(jsonEncode(metadata));
    } catch (e) {
      debugPrint('Save metadata error: $e');
    }
  }
}

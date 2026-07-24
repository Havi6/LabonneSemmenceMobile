import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';

class Sermon {
  final String? id;
  final String title;
  final String description;
  final String author;
  final String duration;
  final String date;
  final String verse;
  final String audioUrl;
  bool isPlaying;

  Sermon({
    this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.duration,
    required this.date,
    required this.verse,
    required this.audioUrl,
    this.isPlaying = false,
  });

  factory Sermon.fromJson(Map<String, dynamic> json) => Sermon(
    id: _readString(json, ['id', '_id']),
    title: _readString(json, ['titre', 'title', 'name']) ?? '',
    description: _readString(json, ['description', 'content', 'summary']) ?? '',
    author:
        _readString(json, ['auteur', 'author', 'preacher', 'speaker', 'pastor']) ?? '',
    duration: _readString(json, ['categorie', 'duration', 'length']) ?? '',
    date: _readString(json, ['date', 'createdAt', 'publishedAt']) ?? '',
    verse: _readString(json, ['verset', 'verse', 'bibleVerse', 'reference']) ?? '',
    audioUrl: _normalizeUrl(_readString(json, ['chemin', 'audioUrl', 'audio', 'fileUrl', 'url'])) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'titre': title,
    'verset': verse,
    'description': description,
    'chemin': audioUrl,
    'date': date,
    'auteur': author,
    'categorie': duration,
  };
}

class Event {
  final String? id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;
  final String label;
  final String? videoUrl;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.label,
    this.videoUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: _readString(json, ['id', '_id']),
    title: _readString(json, ['titre', 'title', 'name']) ?? '',
    description: _readString(json, ['description', 'content', 'summary']) ?? '',
    date: _readString(json, ['date', 'startDate', 'createdAt']) ?? '',
    time: _readString(json, ['heure', 'time', 'hour', 'startTime']) ?? '',
    location: _readString(json, ['lieu', 'location', 'place', 'address']) ?? '',
    imageUrl:
        _normalizeUrl(_readString(json, [
          'image_url',
          'imageUrl',
          'image',
          'coverUrl',
          'thumbnailUrl',
          'url',
        ])) ??
        _fileUrl(_readString(json, ['id', '_id'])),
    label: _readString(json, ['categorie', 'label', 'category', 'type']) ?? '',
    videoUrl: _readString(json, ['videoUrl', 'video', 'streamUrl']),
  );

  Map<String, dynamic> toJson() => {
    'titre': title,
    'description': description,
    'date': date,
    'heure': time,
    'lieu': location,
    if (imageUrl.isNotEmpty) 'image_url': imageUrl,
    'categorie': label,
    if (videoUrl != null && videoUrl!.isNotEmpty) 'videoUrl': videoUrl,
  };
}

class GalleryItem {
  final String? id;
  final String url;
  final String title;

  GalleryItem({this.id, required this.url, required this.title});

  factory GalleryItem.fromJson(Map<String, dynamic> json) => GalleryItem(
    id: _readString(json, ['id', '_id']),
    url:
        _normalizeUrl(_readString(json, ['url', 'fileUrl', 'downloadUrl', 'path'])) ??
        _fileUrl(_readString(json, ['id', '_id'])),
    title:
        _readString(json, ['title', 'name', 'filename', 'originalName']) ?? '',
  );
}

class AppData {
  static const _cacheDuration = Duration(minutes: 5);

  static List<Sermon>? _sermonsCache;
  static List<Event>? _eventsCache;
  static List<GalleryItem>? _galleryCache;
  static DateTime? _sermonsCachedAt;
  static DateTime? _eventsCachedAt;
  static DateTime? _galleryCachedAt;
  static Future<List<Sermon>>? _sermonsRequest;
  static Future<List<Event>>? _eventsRequest;
  static Future<List<GalleryItem>>? _galleryRequest;

  static List<Sermon> get cachedSermons => _sermonsCache ?? const [];

  static Future<List<Sermon>> fetchSermons({
    bool forceRefresh = false,
    bool authenticated = false,
  }) {
    if (!forceRefresh && _isFresh(_sermonsCachedAt) && _sermonsCache != null) {
      return Future.value(_sermonsCache!);
    }
    return _sermonsRequest ??= _loadSermons(authenticated: authenticated);
  }

  static Future<List<Event>> fetchEvents({
    bool forceRefresh = false,
    bool authenticated = false,
  }) {
    if (!forceRefresh && _isFresh(_eventsCachedAt) && _eventsCache != null) {
      return Future.value(_eventsCache!);
    }
    return _eventsRequest ??= _loadEvents(authenticated: authenticated);
  }

  static Future<List<GalleryItem>> fetchGallery({
    bool forceRefresh = false,
    bool authenticated = false,
  }) {
    if (!forceRefresh && _isFresh(_galleryCachedAt) && _galleryCache != null) {
      return Future.value(_galleryCache!);
    }
    return _galleryRequest ??= _loadGallery(authenticated: authenticated);
  }

  static void clearCache() {
    _sermonsCache = null;
    _eventsCache = null;
    _galleryCache = null;
    _sermonsCachedAt = null;
    _eventsCachedAt = null;
    _galleryCachedAt = null;
  }

  static Future<Sermon> createSermon(Sermon sermon) async {
    final data = await ApiClient.instance.post(
      Config.sermonsUrl,
      sermon.toJson(),
      authenticated: true,
    );
    final created = Sermon.fromJson(_readEntity(data));
    _updateSermonsCache(created.id == null ? sermon : created, add: true);
    return created.id == null ? sermon : created;
  }

  static Future<Sermon> updateSermon(Sermon sermon) async {
    final id = _requiredId(sermon.id, 'ce sermon');
    final data = await ApiClient.instance.put(
      '${Config.sermonsUrl}/${Uri.encodeComponent(id)}',
      sermon.toJson(),
      authenticated: true,
    );
    final updated = Sermon.fromJson(_readEntity(data));
    _updateSermonsCache(updated.id == null ? sermon : updated);
    return updated.id == null ? sermon : updated;
  }

  static Future<void> deleteSermon(String id) async {
    await ApiClient.instance.delete(
      '${Config.sermonsUrl}/${Uri.encodeComponent(id)}',
      authenticated: true,
    );
    _sermonsCache = _sermonsCache?.where((item) => item.id != id).toList();
    _sermonsCachedAt = DateTime.now();
  }

  static Future<Event> createEvent(Event event) async {
    final data = await ApiClient.instance.post(
      Config.eventsUrl,
      event.toJson(),
      authenticated: true,
    );
    final created = Event.fromJson(_readEntity(data));
    _updateEventsCache(created.id == null ? event : created, add: true);
    return created.id == null ? event : created;
  }

  static Future<Event> updateEvent(Event event) async {
    final id = _requiredId(event.id, 'cet événement');
    final data = await ApiClient.instance.put(
      '${Config.eventsUrl}/${Uri.encodeComponent(id)}',
      event.toJson(),
      authenticated: true,
    );
    final updated = Event.fromJson(_readEntity(data));
    _updateEventsCache(updated.id == null ? event : updated);
    return updated.id == null ? event : updated;
  }

  static Future<void> deleteEvent(String id) async {
    await ApiClient.instance.delete(
      '${Config.eventsUrl}/${Uri.encodeComponent(id)}',
      authenticated: true,
    );
    _eventsCache = _eventsCache?.where((item) => item.id != id).toList();
    _eventsCachedAt = DateTime.now();
  }

  static Future<void> deleteGalleryItem(String id) async {
    await ApiClient.instance.delete(
      '${Config.filesUrl}/${Uri.encodeComponent(id)}',
      authenticated: true,
    );
    _galleryCache = _galleryCache?.where((item) => item.id != id).toList();
    _galleryCachedAt = DateTime.now();
  }

  static Future<GalleryItem> uploadGalleryItem({
    required Uint8List bytes,
    required String filename,
  }) async {
    final data = await ApiClient.instance.uploadFile(
      '${Config.filesUrl}/upload',
      bytes: bytes,
      filename: filename,
      fields: const {
        'is_public': 'true',
        'usage': 'gallery',
        'legend': '',
        'categorie': '',
      },
      authenticated: true,
    );
    final uploaded = GalleryItem.fromJson(_readEntity(data));
    if (uploaded.url.isEmpty) {
      throw const ApiException(
        'Le serveur n’a pas retourné la photo téléversée.',
      );
    }
    if (_galleryCache != null) {
      _galleryCache = [uploaded, ..._galleryCache!];
      _galleryCachedAt = DateTime.now();
    }
    return uploaded;
  }

  /// Téléverse une ressource associée à un événement ou à un sermon et renvoie
  /// son URL publique utilisable directement par l'entité concernée.
  static Future<String> uploadAsset({
    required Uint8List bytes,
    required String filename,
    required String categorie,
  }) async {
    final data = await ApiClient.instance.uploadFile(
      '${Config.filesUrl}/upload',
      bytes: bytes,
      filename: filename,
      fields: {
        'is_public': 'true',
        'usage': 'cover',
        'legend': '',
        'categorie': categorie,
      },
      authenticated: true,
    );
    final entity = _readEntity(data);
    final url = _normalizeUrl(_readString(entity, [
          'url',
          'fileUrl',
          'downloadUrl',
          'path',
        ])) ??
        _fileUrl(_readString(entity, ['id', '_id']));
    if (url.isEmpty) {
      throw const ApiException('Le serveur n’a pas retourné l’URL du fichier.');
    }
    return url;
  }

  static Future<void> setGalleryVisibility(String id, bool isPublic) async {
    await ApiClient.instance.patch(
      '${Config.filesUrl}/${Uri.encodeComponent(id)}/visibility',
      {'is_public': isPublic},
      authenticated: true,
    );
  }

  static void _updateSermonsCache(Sermon sermon, {bool add = false}) {
    if (_sermonsCache == null) return;
    final index = _sermonsCache!.indexWhere((item) => item.id == sermon.id);
    if (add || index == -1) {
      _sermonsCache = [sermon, ..._sermonsCache!];
    } else {
      _sermonsCache![index] = sermon;
    }
    _sermonsCachedAt = DateTime.now();
  }

  static void _updateEventsCache(Event event, {bool add = false}) {
    if (_eventsCache == null) return;
    final index = _eventsCache!.indexWhere((item) => item.id == event.id);
    if (add || index == -1) {
      _eventsCache = [event, ..._eventsCache!];
    } else {
      _eventsCache![index] = event;
    }
    _eventsCachedAt = DateTime.now();
  }

  static Future<List<Sermon>> _loadSermons({bool authenticated = false}) async {
    try {
      final data = await ApiClient.instance.get(
        Config.sermonsUrl,
        authenticated: authenticated,
      );
      final sermons = _readList(data).map(Sermon.fromJson).toList();
      _sermonsCache = sermons;
      _sermonsCachedAt = DateTime.now();
      return sermons;
    } finally {
      _sermonsRequest = null;
    }
  }

  static Future<List<Event>> _loadEvents({bool authenticated = false}) async {
    try {
      final data = await ApiClient.instance.get(
        Config.eventsUrl,
        authenticated: authenticated,
      );
      final events = _readList(data).map(Event.fromJson).toList();
      _eventsCache = events;
      _eventsCachedAt = DateTime.now();
      return events;
    } finally {
      _eventsRequest = null;
    }
  }

  static Future<List<GalleryItem>> _loadGallery({
    bool authenticated = false,
  }) async {
    try {
      final data = await ApiClient.instance.get(
        '${Config.filesUrl}/public?usage=gallery',
        authenticated: authenticated,
      );
      final gallery = _readList(data)
          .where(_isImage)
          .map(GalleryItem.fromJson)
          .where((item) => item.url.isNotEmpty)
          .toList();
      _galleryCache = gallery;
      _galleryCachedAt = DateTime.now();
      return gallery;
    } finally {
      _galleryRequest = null;
    }
  }

  static bool _isFresh(DateTime? cachedAt) =>
      cachedAt != null && DateTime.now().difference(cachedAt) < _cacheDuration;
}

String _requiredId(String? id, String resource) {
  if (id == null || id.isEmpty) {
    throw ApiException('Identifiant manquant pour $resource.');
  }
  return id;
}

Map<String, dynamic> _readEntity(dynamic data) {
  if (data is! Map<String, dynamic>) return const {};
  final nested = data['data'] ?? data['item'] ?? data['result'];
  return nested is Map<String, dynamic> ? nested : data;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is Map<String, dynamic>) {
      final nested = _readString(value, [
        'url',
        'fileUrl',
        'name',
        'title',
        'path',
        'uri',
        'id',
        '_id'
      ]);
      if (nested != null && nested.isNotEmpty) return nested;
    }
    final text = value.toString();
    if (text.isNotEmpty) return text;
  }
  return null;
}

List<Map<String, dynamic>> _readList(dynamic data) {
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().toList();
  }

  if (data is Map<String, dynamic>) {
    // Liste des clés communes pour les tableaux de données
    const listKeys = [
      'data',
      'items',
      'results',
      'files',
      'sermons',
      'events',
      'item'
    ];
    for (final key in listKeys) {
      final value = data[key];
      if (value is List) {
        return value.whereType<Map<String, dynamic>>().toList();
      }
      // Tentative de recherche récursive si c'est une Map (ex: data: { files: [...] })
      if (value is Map<String, dynamic>) {
        final nested = _readList(value);
        if (nested.isNotEmpty) return nested;
      }
    }
  }

  return const [];
}

bool _isImage(Map<String, dynamic> item) {
  final type = _readString(item, [
    'mimeType',
    'mimetype',
    'type',
    'contentType',
  ])?.toLowerCase();

  final url =
      _readString(item, [
        'url',
        'fileUrl',
        'downloadUrl',
        'path',
        'name',
        'filename',
        'uri',
      ])?.toLowerCase() ??
      '';

  final isImageMime = type?.startsWith('image/') == true;
  final hasImageExtension =
      url.endsWith('.jpg') ||
      url.endsWith('.jpeg') ||
      url.endsWith('.png') ||
      url.endsWith('.webp') ||
      url.endsWith('.gif');

  // Si c'est un endpoint de téléchargement d'un fichier reconnu comme image par le serveur
  final isDownloadEndpoint = url.contains('/download') || url.contains('/files/');

  return isImageMime || hasImageExtension || isDownloadEndpoint;
}

String _fileUrl(String? id) =>
    id == null || id.isEmpty ? '' : _normalizeUrl('${Config.filesUrl}/$id/download')!;

String? _normalizeUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;

  // Si l'URL contient des antislashs, c'est probablement un chemin Windows local au serveur
  if (url.contains('\\')) return null;

  String path = url;
  if (path.startsWith('/')) {
    path = path.substring(1);
  }

  final normalized = '${Config.baseUrl}/$path';
  debugPrint('URL normalisée : $normalized');
  return normalized;
}

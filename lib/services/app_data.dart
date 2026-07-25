import 'package:flutter/foundation.dart';

import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';
import 'package:la_bonne_semence_mobile/models/entities.dart';

export 'package:la_bonne_semence_mobile/models/entities.dart';

class AppData extends ChangeNotifier {
  AppData._();
  static final AppData instance = AppData._();

  static const _cacheDuration = Duration(minutes: 5);

  List<Sermon>? _sermonsCache;
  List<Event>? _eventsCache;
  List<GalleryItem>? _galleryCache;
  DateTime? _sermonsCachedAt;
  DateTime? _eventsCachedAt;
  DateTime? _galleryCachedAt;
  Future<List<Sermon>>? _sermonsRequest;
  Future<List<Event>>? _eventsRequest;
  Future<List<GalleryItem>>? _galleryRequest;

  List<Sermon> get cachedSermons => _sermonsCache ?? const [];
  List<Event> get cachedEvents => _eventsCache ?? const [];
  List<GalleryItem> get cachedGallery => _galleryCache ?? const [];

  /// Renvoie le dernier message reçu du serveur et le réinitialise.
  static String? consumeLastServerMessage() {
    final msg = _AppDataState._lastMsg;
    _AppDataState._lastMsg = null;
    return msg;
  }

  static Future<List<Sermon>> fetchSermons({
    bool forceRefresh = false,
    bool authenticated = false,
  }) => instance._fetchSermons(forceRefresh: forceRefresh, authenticated: authenticated);

  Future<List<Sermon>> _fetchSermons({
    bool forceRefresh = false,
    bool authenticated = false,
  }) {
    if (!forceRefresh && _sermonsCache != null) {
      // Si on a du cache, on le renvoie immédiatement tout en rafraîchissant en arrière-plan
      // si les données sont expirées.
      if (!_isFresh(_sermonsCachedAt)) {
        _loadSermons(authenticated: authenticated);
      }
      return Future.value(_sermonsCache!);
    }
    return _sermonsRequest ??= _loadSermons(authenticated: authenticated);
  }

  static Future<List<Event>> fetchEvents({
    bool forceRefresh = false,
    bool authenticated = false,
  }) => instance._fetchEvents(forceRefresh: forceRefresh, authenticated: authenticated);

  Future<List<Event>> _fetchEvents({
    bool forceRefresh = false,
    bool authenticated = false,
  }) {
    if (!forceRefresh && _eventsCache != null) {
      if (!_isFresh(_eventsCachedAt)) {
        _loadEvents(authenticated: authenticated);
      }
      return Future.value(_eventsCache!);
    }
    return _eventsRequest ??= _loadEvents(authenticated: authenticated);
  }

  static Future<List<GalleryItem>> fetchGallery({
    bool forceRefresh = false,
    bool authenticated = false,
  }) => instance._fetchGallery(forceRefresh: forceRefresh, authenticated: authenticated);

  Future<List<GalleryItem>> _fetchGallery({
    bool forceRefresh = false,
    bool authenticated = false,
  }) {
    if (!forceRefresh && _galleryCache != null) {
      if (!_isFresh(_galleryCachedAt)) {
        _loadGallery(authenticated: authenticated);
      }
      return Future.value(_galleryCache!);
    }
    return _galleryRequest ??= _loadGallery(authenticated: authenticated);
  }

  static void clearCache() => instance._clearCache();

  void _clearCache() {
    _sermonsCache = null;
    _eventsCache = null;
    _galleryCache = null;
    _sermonsCachedAt = null;
    _eventsCachedAt = null;
    _galleryCachedAt = null;
    notifyListeners();
  }

  static Future<Sermon> createSermon(Sermon sermon) => instance._createSermon(sermon);

  Future<Sermon> _createSermon(Sermon sermon) async {
    final data = await ApiClient.instance.post(
      Config.sermonsUrl,
      sermon.toJson(),
      authenticated: true,
    );
    final created = Sermon.fromJson(_readEntity(data));
    _updateSermonsCache(created.id == null ? sermon : created, add: true);
    // Rafraîchissement automatique depuis le serveur pour synchronisation totale
    _loadSermons(authenticated: true);
    return created.id == null ? sermon : created;
  }

  static Future<Sermon> updateSermon(Sermon sermon) => instance._updateSermon(sermon);

  Future<Sermon> _updateSermon(Sermon sermon) async {
    final id = _requiredId(sermon.id, 'ce sermon');
    final data = await ApiClient.instance.put(
      '${Config.sermonsUrl}/${Uri.encodeComponent(id)}',
      sermon.toJson(),
      authenticated: true,
    );
    final updated = Sermon.fromJson(_readEntity(data));
    _updateSermonsCache(updated.id == null ? sermon : updated);
    _loadSermons(authenticated: true);
    return updated.id == null ? sermon : updated;
  }

  static Future<void> deleteSermon(String id) => instance._deleteSermon(id);

  Future<void> _deleteSermon(String id) async {
    final data = await ApiClient.instance.delete(
      '${Config.sermonsUrl}/${Uri.encodeComponent(id)}',
      authenticated: true,
    );
    _readEntity(data);
    _sermonsCache = _sermonsCache?.where((item) => item.id != id).toList();
    _sermonsCachedAt = DateTime.now();
    notifyListeners();
    _loadSermons(authenticated: true);
  }

  static Future<Event> createEvent(Event event) => instance._createEvent(event);

  Future<Event> _createEvent(Event event) async {
    final data = await ApiClient.instance.post(
      Config.eventsUrl,
      event.toJson(),
      authenticated: true,
    );
    final created = Event.fromJson(_readEntity(data));
    _updateEventsCache(created.id == null ? event : created, add: true);
    _loadEvents(authenticated: true);
    return created.id == null ? event : created;
  }

  static Future<Event> updateEvent(Event event) => instance._updateEvent(event);

  Future<Event> _updateEvent(Event event) async {
    final id = _requiredId(event.id, 'cet événement');
    final data = await ApiClient.instance.put(
      '${Config.eventsUrl}/${Uri.encodeComponent(id)}',
      event.toJson(),
      authenticated: true,
    );
    final updated = Event.fromJson(_readEntity(data));
    _updateEventsCache(updated.id == null ? event : updated);
    _loadEvents(authenticated: true);
    return updated.id == null ? event : updated;
  }

  static Future<void> deleteEvent(String id) => instance._deleteEvent(id);

  Future<void> _deleteEvent(String id) async {
    final data = await ApiClient.instance.delete(
      '${Config.eventsUrl}/${Uri.encodeComponent(id)}',
      authenticated: true,
    );
    _readEntity(data);
    _eventsCache = _eventsCache?.where((item) => item.id != id).toList();
    _eventsCachedAt = DateTime.now();
    notifyListeners();
    _loadEvents(authenticated: true);
  }

  static Future<void> deleteGalleryItem(String id) => instance._deleteGalleryItem(id);

  Future<void> _deleteGalleryItem(String id) async {
    final data = await ApiClient.instance.delete(
      '${Config.filesUrl}/${Uri.encodeComponent(id)}',
      authenticated: true,
    );
    _readEntity(data);
    _galleryCache = _galleryCache?.where((item) => item.id != id).toList();
    _galleryCachedAt = DateTime.now();
    notifyListeners();
    _loadGallery(authenticated: true);
  }

  static Future<GalleryItem> uploadGalleryItem({
    required Uint8List bytes,
    required String filename,
    String legend = '',
  }) => instance._uploadGalleryItem(bytes: bytes, filename: filename, legend: legend);

  Future<GalleryItem> _uploadGalleryItem({
    required Uint8List bytes,
    required String filename,
    String legend = '',
  }) async {
    final data = await ApiClient.instance.uploadFile(
      '${Config.filesUrl}/upload',
      bytes: bytes,
      filename: filename,
      fields: {
        'is_public': 'true',
        'usage': 'gallery',
        'legend': legend,
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
      notifyListeners();
    }
    _loadGallery(authenticated: true);
    return uploaded;
  }

  /// Téléverse une ressource associée à un événement ou à un sermon et renvoie
  /// son URL publique utilisable directement par l'entité concernée.
  static Future<String> uploadAsset({
    required Uint8List bytes,
    required String filename,
    required String categorie,
    Map<String, String> additionalFields = const {},
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
        ...additionalFields,
      },
      authenticated: true,
    );
    final entity = _readEntity(data);
    final url = normalizeUrl(readString(entity, [
          'url',
          'fileUrl',
          'downloadUrl',
          'path',
        ])) ??
        fileUrl(readString(entity, ['id', '_id']));
    if (url.isEmpty) {
      throw const ApiException('Le serveur n’a pas retourné l’URL du fichier.');
    }
    return url;
  }

  static Future<void> setGalleryVisibility(String id, bool isPublic) => instance._setGalleryVisibility(id, isPublic);

  Future<void> _setGalleryVisibility(String id, bool isPublic) async {
    final data = await ApiClient.instance.patch(
      '${Config.filesUrl}/${Uri.encodeComponent(id)}/visibility',
      {'is_public': isPublic},
      authenticated: true,
    );
    _readEntity(data);
    // On ne notifie pas forcément ici si on ne gère pas la visibilité dans le cache local
  }

  void _updateSermonsCache(Sermon sermon, {bool add = false}) {
    if (_sermonsCache == null) return;
    final list = List<Sermon>.from(_sermonsCache!);
    final index = list.indexWhere((item) => item.id == sermon.id);
    if (add || index == -1) {
      list.add(sermon);
    } else {
      list[index] = sermon;
    }
    // Tri par date décroissante
    list.sort((a, b) => b.date.compareTo(a.date));
    _sermonsCache = list;
    _sermonsCachedAt = DateTime.now();
    notifyListeners();
  }

  void _updateEventsCache(Event event, {bool add = false}) {
    if (_eventsCache == null) return;
    final list = List<Event>.from(_eventsCache!);
    final index = list.indexWhere((item) => item.id == event.id);
    if (add || index == -1) {
      list.add(event);
    } else {
      list[index] = event;
    }
    // Tri par date décroissante
    list.sort((a, b) => b.date.compareTo(a.date));
    _eventsCache = list;
    _eventsCachedAt = DateTime.now();
    notifyListeners();
  }

  Future<List<Sermon>> _loadSermons({bool authenticated = false}) async {
    try {
      final data = await ApiClient.instance.get(
        Config.sermonsUrl,
        authenticated: authenticated,
      );
      final sermons = _readList(data).map(Sermon.fromJson).toList();
      _sermonsCache = sermons;
      _sermonsCachedAt = DateTime.now();
      notifyListeners();
      return sermons;
    } finally {
      _sermonsRequest = null;
    }
  }

  Future<List<Event>> _loadEvents({bool authenticated = false}) async {
    try {
      final data = await ApiClient.instance.get(
        Config.eventsUrl,
        authenticated: authenticated,
      );
      final events = _readList(data).map(Event.fromJson).toList();
      _eventsCache = events;
      _eventsCachedAt = DateTime.now();
      notifyListeners();
      return events;
    } finally {
      _eventsRequest = null;
    }
  }

  Future<List<GalleryItem>> _loadGallery({
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
      notifyListeners();
      return gallery;
    } finally {
      _galleryRequest = null;
    }
  }

  bool _isFresh(DateTime? cachedAt) =>
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

  // Capture du message serveur s'il existe
  final msg = data['message'] ?? data['msg'];
  if (msg != null) _AppDataState._lastMsg = msg.toString();

  final nested = data['data'] ?? data['item'] ?? data['result'];
  return nested is Map<String, dynamic> ? nested : data;
}

// Utilisation d'une classe privée interne pour stocker l'état statique du message
// afin d'éviter les problèmes d'accès si _readEntity est une fonction top-level.
class _AppDataState {
  static String? _lastMsg;
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
  final type = readString(item, [
    'mimeType',
    'mimetype',
    'type',
    'contentType',
  ])?.toLowerCase();

  final url =
      readString(item, [
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

import 'package:flutter/foundation.dart';
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
  final String imageUrl;
  final String imageCaption;
  final bool autoDelete;
  final int? deleteAfterDays;
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
    this.imageUrl = '',
    this.imageCaption = '',
    this.autoDelete = false,
    this.deleteAfterDays,
    this.isPlaying = false,
  });

  factory Sermon.fromJson(Map<String, dynamic> json) => Sermon(
    id: readString(json, ['id', '_id']),
    title: readString(json, ['titre', 'title', 'name']) ?? '',
    description: readString(json, ['description', 'content', 'summary']) ?? '',
    author:
        readString(json, ['auteur', 'author', 'preacher', 'speaker', 'pastor']) ?? '',
    duration: readString(json, ['categorie', 'duration', 'length']) ?? '',
    date: readString(json, ['date', 'createdAt', 'publishedAt']) ?? '',
    verse: readString(json, ['verset', 'verse', 'bibleVerse', 'reference']) ?? '',
    audioUrl: normalizeUrl(readString(json, ['chemin', 'audioUrl', 'audio', 'fileUrl', 'url'])) ?? '',
    imageUrl: normalizeUrl(readString(json, ['image_url', 'imageUrl', 'image'])) ?? '',
    imageCaption: readString(json, ['legende', 'caption', 'imageCaption', 'legend']) ?? '',
    autoDelete: readBool(json, ['auto_delete', 'autoDelete']) ?? false,
    deleteAfterDays: readInt(json, ['delete_after_days', 'deleteAfterDays']),
  );

  Map<String, dynamic> toJson() => {
    'titre': title,
    'verset': verse,
    'description': description,
    'chemin': audioUrl,
    'date': date,
    'auteur': author,
    'categorie': duration,
    'image_url': imageUrl,
    'legende': imageCaption,
    'auto_delete': autoDelete,
    'delete_after_days': deleteAfterDays,
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
  final bool autoDelete;
  final int? deleteAfterDays;

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
    this.autoDelete = false,
    this.deleteAfterDays,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: readString(json, ['id', '_id']),
    title: readString(json, ['titre', 'title', 'name']) ?? '',
    description: readString(json, ['description', 'content', 'summary']) ?? '',
    date: readString(json, ['date', 'startDate', 'createdAt']) ?? '',
    time: readString(json, ['heure', 'time', 'hour', 'startTime']) ?? '',
    location: readString(json, ['lieu', 'location', 'place', 'address']) ?? '',
    imageUrl:
        normalizeUrl(readString(json, [
          'image_url',
          'imageUrl',
          'image',
          'coverUrl',
          'thumbnailUrl',
          'url',
        ])) ??
        fileUrl(readString(json, ['id', '_id'])),
    label: readString(json, ['categorie', 'label', 'category', 'type']) ?? '',
    videoUrl: readString(json, ['videoUrl', 'video', 'streamUrl']),
    autoDelete: readBool(json, ['auto_delete', 'autoDelete']) ?? false,
    deleteAfterDays: readInt(json, ['delete_after_days', 'deleteAfterDays']),
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
    'auto_delete': autoDelete,
    'delete_after_days': deleteAfterDays,
  };
}

class GalleryItem {
  final String? id;
  final String url;
  final String title;

  GalleryItem({this.id, required this.url, required this.title});

  factory GalleryItem.fromJson(Map<String, dynamic> json) => GalleryItem(
    id: readString(json, ['id', '_id']),
    url:
        normalizeUrl(readString(json, ['url', 'fileUrl', 'downloadUrl', 'path'])) ??
        fileUrl(readString(json, ['id', '_id'])),
    title:
        readString(json, ['legende', 'caption', 'legend', 'title', 'name', 'filename', 'originalName']) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'title': title,
  };
}

class MotDuPasteur {
  final String? id;
  final String title;
  final String content;
  final String label;
  final String author;
  final DateTime? createdAt;
  final bool autoDelete;
  final int? deleteAfterDays;

  MotDuPasteur({
    this.id,
    required this.title,
    required this.content,
    required this.label,
    required this.author,
    this.createdAt,
    this.autoDelete = false,
    this.deleteAfterDays,
  });

  factory MotDuPasteur.fromJson(Map<String, dynamic> json) {
    final dateStr = readString(json, ['createdAt', 'date', 'publishedAt']);
    return MotDuPasteur(
      id: readString(json, ['id', '_id']),
      title: readString(json, ['title', 'titre']) ?? '',
      content: readString(json, ['content', 'contenu']) ?? '',
      label: readString(json, ['label', 'libelle']) ?? '',
      author: readString(json, ['author', 'auteur']) ?? '',
      createdAt: dateStr != null ? DateTime.tryParse(dateStr) : null,
      autoDelete: readBool(json, ['auto_delete', 'autoDelete']) ?? false,
      deleteAfterDays: readInt(json, ['delete_after_days', 'deleteAfterDays']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'label': label,
        'author': author,
        'auto_delete': autoDelete,
        'delete_after_days': deleteAfterDays,
      };
}

String? readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is Map<String, dynamic>) {
      final nested = readString(value, [
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

bool? readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is num) return value != 0;
  }
  return null;
}

int? readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

String fileUrl(String? id) =>
    id == null || id.isEmpty ? '' : normalizeUrl('${Config.filesUrl}/$id/download')!;

String? normalizeUrl(String? url) {
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

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
    this.audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Placeholder audio
    this.isPlaying = false,
  });

  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      id: _readString(json, ['id', '_id']),
      title: _readString(json, ['title', 'name']) ?? 'Enseignement',
      description: _readString(json, ['description', 'content', 'summary']) ?? '',
      author: _readString(json, ['author', 'preacher', 'speaker', 'pastor']) ?? 'La Bonne Semence',
      duration: _readString(json, ['duration', 'length']) ?? '',
      date: _readString(json, ['date', 'createdAt', 'publishedAt']) ?? '',
      verse: _readString(json, ['verse', 'bibleVerse', 'reference']) ?? '',
      audioUrl: _readString(json, ['audioUrl', 'audio', 'fileUrl', 'url']) ??
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    );
  }
}

class Event {
  final String? id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;
  final String label; // jeunesse, culte, prière, social
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

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: _readString(json, ['id', '_id']),
      title: _readString(json, ['title', 'name']) ?? 'Evenement',
      description: _readString(json, ['description', 'content', 'summary']) ?? '',
      date: _readString(json, ['date', 'startDate', 'createdAt']) ?? '',
      time: _readString(json, ['time', 'hour', 'startTime']) ?? '',
      location: _readString(json, ['location', 'place', 'address']) ?? '',
      imageUrl: _readString(json, ['imageUrl', 'image', 'coverUrl', 'thumbnailUrl', 'url']) ??
          'https://images.unsplash.com/photo-1438232992991-995b7058bbb3',
      label: _readString(json, ['label', 'category', 'type']) ?? 'culte',
      videoUrl: _readString(json, ['videoUrl', 'video', 'streamUrl']),
    );
  }
}

class GalleryItem {
  final String? id;
  final String url;
  final String title;

  GalleryItem({this.id, required this.url, required this.title});

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: _readString(json, ['id', '_id']),
      url: _readString(json, ['url', 'fileUrl', 'downloadUrl', 'path']) ??
          _fileUrl(_readString(json, ['id', '_id'])),
      title: _readString(json, ['title', 'name', 'filename', 'originalName']) ?? 'Photo',
    );
  }
}

class AppData {
  static final List<Sermon> sermons = List.generate(
    20,
    (index) => Sermon(
      title: index == 0 ? "La puissance de la foi" : 
             index == 1 ? "Marcher dans l'Esprit" :
             index == 2 ? "La grâce infinie" :
             index == 3 ? "Le pardon libérateur" : 
             index == 4 ? "Servir avec amour" : "Sermon ${index + 1} : Enseignement",
      description: "Une exploration profonde de la manière dont la foi peut transformer nos vies quotidiennes.",
      author: index % 2 == 0 ? "Pasteur Jean Dupont" : "Pasteur Marc Solo",
      duration: "${(20 + index % 40)}:45",
      date: "${index + 1}/10/2023",
      verse: "Car nous marchons par la foi et non par la vue. - 2 Cor 5:7",
    ),
  );

  static final List<Event> events = [
    Event(
      title: "Culte d'Adoration",
      description: "Venez célébrer le Seigneur avec nous ce dimanche matin.",
      date: "Dim. 12 Nov.",
      time: "09:00",
      location: "Temple Principal",
      label: "culte",
      imageUrl: "https://images.unsplash.com/photo-1438232992991-995b7058bbb3",
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ),
    Event(
      title: "Soirée Jeunesse",
      description: "Une soirée d'échange et de partage pour tous les jeunes.",
      date: "Sam. 18 Nov.",
      time: "18:00",
      location: "Salle Polyvalente",
      label: "jeunesse",
      imageUrl: "https://images.unsplash.com/photo-1523240795612-9a054b0db644",
    ),
    Event(
      title: "Intercession",
      description: "Réunion de prière fervente pour les besoins de l'église.",
      date: "Mer. 15 Nov.",
      time: "17:30",
      location: "Chapelle haute",
      label: "prière",
      imageUrl: "https://images.unsplash.com/photo-1515162305285-0293e4767cc2",
    ),
    Event(
      title: "Aide Alimentaire",
      description: "Distribution de vivres pour les familles nécessiteuses.",
      date: "Sam. 25 Nov.",
      time: "10:00",
      location: "Parking Ouest",
      label: "social",
      imageUrl: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c",
    ),
    Event(
      title: "Concert Chorale",
      description: "Grande soirée de louange avec la chorale unifiée.",
      date: "Dim. 26 Nov.",
      time: "16:00",
      location: "Esplanade",
      label: "culte",
      imageUrl: "https://images.unsplash.com/photo-1511112181701-383197017267",
    ),
    Event(
      title: "Camp de Vacances",
      description: "Inscriptions ouvertes pour le camp des ados de décembre.",
      date: "Lun. 04 Déc.",
      time: "08:00",
      location: "Bureau Accueil",
      label: "jeunesse",
      imageUrl: "https://images.unsplash.com/photo-1529070538774-1843cb3265df",
    ),
    Event(
      title: "Vigile de Nuit",
      description: "Passer la nuit dans la présence de Dieu.",
      date: "Ven. 1 Déc.",
      time: "22:00",
      location: "Temple Principal",
      label: "prière",
      imageUrl: "https://images.unsplash.com/photo-1507692049790-de58290a4334",
    ),
    Event(
      title: "Visite Hôpital",
      description: "Accompagner et prier pour les malades de la ville.",
      date: "Mar. 21 Nov.",
      time: "14:00",
      location: "Rdv Accueil",
      label: "social",
      imageUrl: "https://images.unsplash.com/photo-1516627145497-ae6968895b74",
    ),
    Event(
      title: "Étude Biblique",
      description: "Approfondir la parole de Dieu ensemble.",
      date: "Jeu. 16 Nov.",
      time: "18:00",
      location: "Salle B",
      label: "culte",
      imageUrl: "https://images.unsplash.com/photo-1544427920-c49ccfb85579",
    ),
    Event(
      title: "Sortie Sportive",
      description: "Tournoi de football inter-quartiers.",
      date: "Sam. 02 Déc.",
      time: "15:00",
      location: "Stade Municipal",
      label: "jeunesse",
      imageUrl: "https://images.unsplash.com/photo-1519491050282-cf00c82424b4",
    ),
  ];

  static final List<GalleryItem> gallery = [
    GalleryItem(url: 'https://images.unsplash.com/photo-1544427920-c49ccfb85579', title: 'Culte du Dimanche'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2', title: 'Moment de Louange'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3', title: 'Étude Biblique'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1529070538774-1843cb3265df', title: 'Événement Communautaire'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1519491050282-cf00c82424b4', title: 'Chorale des Jeunes'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1478147427282-58a87a120781', title: 'Baptêmes'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1507692049790-de58290a4334', title: 'Sortie en plein air'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1511112181701-383197017267', title: 'Conférence annuelle'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1516627145497-ae6968895b74', title: 'Atelier Enfants'),
    GalleryItem(url: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644', title: 'Réunion de prière'),
  ];

  static Future<List<Sermon>> fetchSermons() async {
    final data = await ApiClient.instance.get(Config.sermonsUrl);
    return _readList(data).map((item) => Sermon.fromJson(item)).toList();
  }

  static Future<List<Event>> fetchEvents() async {
    final data = await ApiClient.instance.get(Config.eventsUrl);
    return _readList(data).map((item) => Event.fromJson(item)).toList();
  }

  static Future<List<GalleryItem>> fetchGallery() async {
    final data = await ApiClient.instance.get(Config.filesUrl);
    return _readList(data)
        .where((item) => _isImage(item))
        .map((item) => GalleryItem.fromJson(item))
        .toList();
  }
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;

    if (value is Map<String, dynamic>) {
      final nested = _readString(value, ['url', 'fileUrl', 'name', 'title']);
      if (nested != null && nested.isNotEmpty) return nested;
    }

    final text = value.toString();
    if (text.isNotEmpty) return text;
  }

  return null;
}

List<Map<String, dynamic>> _readList(dynamic data) {
  final rawList = data is List
      ? data
      : data is Map<String, dynamic>
          ? (data['data'] ?? data['items'] ?? data['results'] ?? data['files'] ?? data['sermons'] ?? data['events'])
          : null;

  if (rawList is! List) {
    return const [];
  }

  return rawList.whereType<Map<String, dynamic>>().toList();
}

bool _isImage(Map<String, dynamic> item) {
  final type = _readString(item, ['mimeType', 'mimetype', 'type', 'contentType'])?.toLowerCase();
  final url = _readString(item, ['url', 'fileUrl', 'downloadUrl', 'path', 'name', 'filename'])?.toLowerCase() ?? '';

  return type?.startsWith('image/') == true ||
      url.endsWith('.jpg') ||
      url.endsWith('.jpeg') ||
      url.endsWith('.png') ||
      url.endsWith('.webp') ||
      url.endsWith('.gif');
}

String _fileUrl(String? id) {
  if (id == null || id.isEmpty) {
    return 'https://images.unsplash.com/photo-1544427920-c49ccfb85579';
  }

  return '${Config.filesUrl}/$id/download';
}

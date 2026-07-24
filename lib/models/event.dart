class Event {
  const Event({
    this.id,
    required this.titre,
    required this.lieu,
    required this.description,
    this.imageUrl,
    required this.categorie,
    required this.heure,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String titre, lieu, description, categorie, heure, date;
  final String? imageUrl;
  final DateTime? createdAt, updatedAt;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: (json['id'] ?? json['_id'])?.toString(),
    titre: (json['titre'] ?? json['title'] ?? '').toString(),
    lieu: (json['lieu'] ?? json['location'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    imageUrl: (json['image_url'] ?? json['imageUrl'])?.toString(),
    categorie: (json['categorie'] ?? json['category'] ?? '').toString(),
    heure: (json['heure'] ?? json['time'] ?? '').toString(),
    date: (json['date'] ?? '').toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()),
    updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'titre': titre, 'lieu': lieu, 'description': description,
    if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
    'categorie': categorie, 'heure': heure, 'date': date,
  };
}

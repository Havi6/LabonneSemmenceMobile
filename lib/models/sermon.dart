class Sermon {
  const Sermon({
    this.id,
    required this.titre,
    required this.verset,
    required this.description,
    required this.chemin,
    this.imageUrl,
    required this.date,
    required this.auteur,
    required this.categorie,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String titre, verset, description, chemin, date, auteur, categorie;
  final String? imageUrl;
  final DateTime? createdAt, updatedAt;

  factory Sermon.fromJson(Map<String, dynamic> json) => Sermon(
    id: (json['id'] ?? json['_id'])?.toString(),
    titre: (json['titre'] ?? json['title'] ?? '').toString(),
    verset: (json['verset'] ?? json['verse'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    chemin: (json['chemin'] ?? json['audioUrl'] ?? '').toString(),
    imageUrl: (json['image_url'] ?? json['imageUrl'])?.toString(),
    date: (json['date'] ?? '').toString(),
    auteur: (json['auteur'] ?? json['author'] ?? '').toString(),
    categorie: (json['categorie'] ?? json['category'] ?? '').toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()),
    updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'titre': titre, 'verset': verset, 'description': description,
    'chemin': chemin,
    if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
    'date': date, 'auteur': auteur, 'categorie': categorie,
  };
}

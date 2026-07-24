class ContactMessage {
  const ContactMessage({
    required this.id,
    required this.nom,
    required this.email,
    required this.sujet,
    required this.contenu,
    this.createdAt,
  });

  final String id;
  final String nom;
  final String email;
  final String sujet;
  final String contenu;
  final DateTime? createdAt;

  factory ContactMessage.fromJson(Map<String, dynamic> json) => ContactMessage(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    nom: (json['nom'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    sujet: (json['sujet'] ?? json['subject'] ?? '').toString(),
    contenu: (json['contenu'] ?? json['message'] ?? '').toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'nom': nom, 'email': email, 'sujet': sujet, 'contenu': contenu,
  };
}

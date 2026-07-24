class GalleryFile {
  const GalleryFile({
    required this.id, required this.filename, required this.originalName,
    required this.legend, required this.usage, required this.categorie,
    required this.mimetype, required this.size, required this.uploaderId,
    required this.isPublic, this.createdAt, this.url,
  });

  final String id, filename, originalName, legend, usage, categorie, mimetype, uploaderId;
  final int size;
  final bool isPublic;
  final DateTime? createdAt;
  final String? url;

  factory GalleryFile.fromJson(Map<String, dynamic> json) => GalleryFile(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    filename: (json['filename'] ?? '').toString(),
    originalName: (json['original_name'] ?? json['originalName'] ?? '').toString(),
    legend: (json['legend'] ?? '').toString(),
    usage: (json['usage'] ?? '').toString(),
    categorie: (json['categorie'] ?? '').toString(),
    mimetype: (json['mimetype'] ?? json['mimeType'] ?? '').toString(),
    size: int.tryParse((json['size'] ?? 0).toString()) ?? 0,
    uploaderId: (json['uploader_id'] ?? json['uploaderId'] ?? '').toString(),
    isPublic: json['is_public'] == true || json['isPublic'] == true,
    createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()),
    url: (json['url'] ?? json['fileUrl'] ?? json['downloadUrl'])?.toString(),
  );
}

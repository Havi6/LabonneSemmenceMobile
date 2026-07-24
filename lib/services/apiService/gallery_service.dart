import 'dart:typed_data';

import 'package:la_bonne_semence_mobile/models/gallery_file.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';
import 'package:la_bonne_semence_mobile/services/apiService/resource_helpers.dart';

class GalleryService {
  GalleryService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<List<GalleryFile>> fetchPublic({String usage = 'gallery'}) async {
    final data = await _client.get('${Config.filesUrl}/public?usage=${Uri.encodeQueryComponent(usage)}');
    return readApiList(data).map(GalleryFile.fromJson).toList();
  }

  Future<GalleryFile> upload({
    required Uint8List bytes,
    required String filename,
    bool isPublic = true,
    String legend = '',
    String usage = 'gallery',
    String categorie = '',
  }) async => GalleryFile.fromJson(readApiEntity(await _client.uploadFile(
    '${Config.filesUrl}/upload',
    bytes: bytes,
    filename: filename,
    authenticated: true,
    fields: {
      'is_public': isPublic.toString(), 'legend': legend,
      'usage': usage, 'categorie': categorie,
    },
  )));

  Future<void> setVisibility(String id, bool isPublic) => _client.patch(
    '${Config.filesUrl}/${Uri.encodeComponent(id)}/visibility',
    {'is_public': isPublic},
    authenticated: true,
  );

  Future<void> delete(String id) => _client.delete(
    '${Config.filesUrl}/${Uri.encodeComponent(id)}', authenticated: true,
  );
}

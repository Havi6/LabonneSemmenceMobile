import 'package:la_bonne_semence_mobile/models/sermon.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';
import 'package:la_bonne_semence_mobile/services/apiService/resource_helpers.dart';

class SermonService {
  SermonService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<List<Sermon>> fetchAll() async =>
      readApiList(await _client.get(Config.sermonsUrl)).map(Sermon.fromJson).toList();
  Future<Sermon> create(Sermon sermon) async => Sermon.fromJson(readApiEntity(
      await _client.post(Config.sermonsUrl, sermon.toJson(), authenticated: true)));
  Future<Sermon> update(Sermon sermon) async => Sermon.fromJson(readApiEntity(await _client.put(
      '${Config.sermonsUrl}/${Uri.encodeComponent(_id(sermon.id))}', sermon.toJson(), authenticated: true)));
  Future<void> delete(String id) => _client.delete(
      '${Config.sermonsUrl}/${Uri.encodeComponent(id)}', authenticated: true);
}

String _id(String? id) {
  if (id == null || id.isEmpty) throw const ApiException('Identifiant manquant.');
  return id;
}

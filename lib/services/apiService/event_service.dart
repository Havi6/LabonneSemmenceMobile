import 'package:la_bonne_semence_mobile/models/event.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';
import 'package:la_bonne_semence_mobile/services/apiService/resource_helpers.dart';

class EventService {
  EventService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<List<Event>> fetchAll() async =>
      readApiList(await _client.get(Config.eventsUrl)).map(Event.fromJson).toList();
  Future<Event> create(Event event) async => Event.fromJson(
      readApiEntity(await _client.post(Config.eventsUrl, event.toJson(), authenticated: true)));
  Future<Event> update(Event event) async => Event.fromJson(readApiEntity(await _client.put(
      '${Config.eventsUrl}/${Uri.encodeComponent(_id(event.id))}', event.toJson(), authenticated: true)));
  Future<void> delete(String id) => _client.delete(
      '${Config.eventsUrl}/${Uri.encodeComponent(id)}', authenticated: true);
}

String _id(String? id) {
  if (id == null || id.isEmpty) throw const ApiException('Identifiant manquant.');
  return id;
}

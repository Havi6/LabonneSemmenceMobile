import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';
import 'package:la_bonne_semence_mobile/models/contact_message.dart';

class ContentService {
  ContentService._();

  static final ContentService instance = ContentService._();

  Future<void> sendContact({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await ApiClient.instance.post(Config.contactsUrl, {
      'nom': name,
      'email': email,
      'sujet': subject,
      'contenu': message,
    });
  }

  Future<List<ContactMessage>> fetchContacts() async {
    final data = await ApiClient.instance.get(
      Config.contactsUrl,
      authenticated: true,
    );
    final items = data is List
        ? data
        : data is Map<String, dynamic>
        ? data['data'] ?? data['contacts'] ?? data['items']
        : null;
    return items is List
        ? items.whereType<Map<String, dynamic>>().map(ContactMessage.fromJson).toList()
        : const [];
  }

  Future<void> deleteContact(String id) => ApiClient.instance.delete(
    '${Config.contactsUrl}/${Uri.encodeComponent(id)}',
    authenticated: true,
  );

  Future<Map<String, dynamic>> createDonation({
    required String name,
    required String phone,
    required num amount,
  }) async {
    final data = await ApiClient.instance.post(Config.donationsUrl, {
      'name': name,
      'phone': phone,
      'amount': amount,
    });

    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> monetbilConfig() async {
    final data = await ApiClient.instance.get(Config.monetbilConfigUrl);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}

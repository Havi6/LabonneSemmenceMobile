import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';

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
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
    });
  }

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

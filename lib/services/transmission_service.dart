import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fladder/models/settings/client_settings_model.dart';
import 'package:fladder/util/fladder_config.dart';

class TransmissionService {
  final String? serverUrl;

  TransmissionService(this.serverUrl);

  Future<Map<String, dynamic>?> fetchTransmissionStats() async {
    if (serverUrl == null || serverUrl!.isEmpty) {
      return null;
    }

    final uri = Uri.parse('$serverUrl/transmission-api');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // Ignore errors silently for background polling
    }
    return null;
  }
}

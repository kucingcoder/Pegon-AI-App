import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransliterationService {
  final String _baseUrl = 'https://rust.pegon.ai';

  Future<String?> _getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session');
  }

  Future<String> transliterateText(String text, bool harakat) async {
    final session = await _getSession();

    // Note: Assuming API works with or without session, but sending if available is safer for tracking/limits
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    final body = jsonEncode({'text': text, 'harakat': harakat});

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/transliteration/text'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? '';
      } else if (response.statusCode == 403 &&
          response.body.contains('Transliteration limit reached')) {
        throw 'Batas harian akun gratis terlewati';
      } else {
        throw 'Failed to transliterate: ${response.statusCode}';
      }
    } catch (e) {
      if (e is String) rethrow;
      throw Exception('Error: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImageTransliterationService {
  final String _baseUrl = 'https://rust.pegon.ai';

  Future<String?> _getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session');
  }

  Future<Map<String, dynamic>> getHistory({int page = 1}) async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/transliteration/image/history?page=$page'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to load history: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Future<Map<String, dynamic>> getDetail(String id) async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/transliteration/image/history/read?id=$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to load detail: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Future<void> updateTitle(String id, String title) async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    final body = jsonEncode({'id': id, 'title': title});

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/transliteration/image/history/update-title'),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw 'Failed to update title: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error updating title: $e';
    }
  }
}

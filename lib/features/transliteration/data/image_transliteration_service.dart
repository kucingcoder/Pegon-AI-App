import 'dart:convert';
import 'package:app/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ImageTransliterationService {
  final String _baseUrl = ApiConstants.baseUrl;

  Future<String?> _getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session');
  }

  Future<String> uploadImage(String filePath) async {
    final session = await _getSession();
    final headers = {if (session != null) 'Cookie': session};

    final uri = Uri.parse('$_baseUrl/api/transliteration/image');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    final mimeType = lookupMimeType(filePath);
    MediaType? contentType;
    if (mimeType != null) {
      contentType = MediaType.parse(mimeType);
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        filePath,
        contentType: contentType,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['history']; // Returns history ID
      } else {
        throw 'Failed to upload image: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw 'Koneksi terputus, coba lagi!';
      }
      throw 'Error uploading image: $e';
    }
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
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw 'Koneksi terputus, coba lagi!';
      }
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
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw 'Koneksi terputus, coba lagi!';
      }
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
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw 'Koneksi terputus, coba lagi!';
      }
      throw 'Error updating title: $e';
    }
  }
}

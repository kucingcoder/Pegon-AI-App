import 'dart:convert';
import 'package:app/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'models/profile_model.dart';

class ProfileService {
  final String _baseUrl = ApiConstants.baseUrl;

  Future<String?> _getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session');
  }

  Future<ProfileData> getProfile() async {
    try {
      final session = await _getSession();
      if (session == null) throw Exception('No session found');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: {'Content-Type': 'application/json', 'Cookie': session},
      );

      if (response.statusCode == 200) {
        return ProfileData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw Exception('Koneksi terputus, coba lagi!');
      }
      rethrow;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final session = await _getSession();
      if (session == null) throw Exception('No session found');

      // Use MultipartRequest to handle "Form Data" (and files if needed)
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/api/profile/update'),
      );

      request.headers['Cookie'] = session;

      data.forEach((key, value) {
        if (key != 'photo_profile' && value != null) {
          request.fields[key] = value.toString();
        }
      });

      if (data.containsKey('photo_profile') &&
          data['photo_profile'] != null &&
          data['photo_profile'].isNotEmpty) {
        final filePath = data['photo_profile'];
        final mimeType = lookupMimeType(filePath);

        MediaType? mediaType;
        if (mimeType != null) {
          final split = mimeType.split('/');
          mediaType = MediaType(split[0], split[1]);
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'photo_profile',
            filePath,
            contentType: mediaType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return true;
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        throw Exception('Koneksi terputus, coba lagi!');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final session = await _getSession();
    if (session != null) {
      try {
        await http.get(
          Uri.parse('$_baseUrl/api/logout'),
          headers: {'Cookie': session},
        );
      } catch (e) {
        // Ignore errors during logout, just proceed to clear local session
        print('Logout error: $e');
      }
    }
  }
}

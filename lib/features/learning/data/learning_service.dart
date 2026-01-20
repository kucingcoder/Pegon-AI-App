import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/level_check_response.dart';
import 'models/level_update_response.dart';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class LearningService {
  final String _baseUrl = 'https://rust.pegon.ai';

  Future<LevelCheckResponse?> checkLevelStage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('session');

      if (session == null) {
        throw Exception('No session found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/check/level-stage'),
        headers: {'Content-Type': 'application/json', 'Cookie': session},
      );

      if (response.statusCode == 200) {
        return LevelCheckResponse.fromJson(jsonDecode(response.body));
      } else {
        print(
          'Learning service error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Learning service error: $e');
      return null;
    }
  }

  Future<LevelUpdateResponse?> updateLevelStage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('session');

      if (session == null) {
        throw Exception('No session found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/check/update-level-stage'),
        headers: {'Content-Type': 'application/json', 'Cookie': session},
      );

      if (response.statusCode == 200) {
        return LevelUpdateResponse.fromJson(jsonDecode(response.body));
      } else {
        print(
          'Learning update error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Learning update error: $e');
      return null;
    }
  }

  Future<LevelUpdateResponse?> checkRead(String guess, String real) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('session');

      if (session == null) {
        throw Exception('No session found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/check/read'),
        headers: {'Content-Type': 'application/json', 'Cookie': session},
        body: jsonEncode({'guess': guess, 'real': real}),
      );

      if (response.statusCode == 200) {
        return LevelUpdateResponse.fromJson(jsonDecode(response.body));
      } else {
        print(
          'Learning check read error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Learning check read error: $e');
      return null;
    }
  }

  Future<LevelUpdateResponse?> checkWrite(
    String filePath,
    String realText,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('session');

      if (session == null) {
        throw Exception('No session found');
      }

      final uri = Uri.parse('$_baseUrl/api/check/write');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Cookie'] = session;
      request.fields['real_text'] = realText;

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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return LevelUpdateResponse.fromJson(jsonDecode(response.body));
      } else {
        print(
          'Learning check write error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Learning check write error: $e');
      return null;
    }
  }
}

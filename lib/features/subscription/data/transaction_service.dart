import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final String _baseUrl = 'https://rust.pegon.ai';

  Future<String?> _getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session');
  }

  Future<String> upgradeToPremium() async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/transaction/upgrade-to-premium'),
        headers: headers,
        body: jsonEncode(
          {},
        ), // Empty body as per description imply it's a trigger
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']; // Returns transaction ID
      } else {
        throw 'Failed to initiate transaction: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Future<Map<String, dynamic>> getTransactionInfo(String id) async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/transaction/history/info?id=$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to load transaction info: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Future<String> getTransactionStatus(String id) async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/transaction/history/status?id=$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      } else {
        throw 'Failed to load status: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory({int page = 1}) async {
    final session = await _getSession();
    final headers = {
      'Content-Type': 'application/json',
      if (session != null) 'Cookie': session,
    };

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/transaction/history?page=$page'),
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
}

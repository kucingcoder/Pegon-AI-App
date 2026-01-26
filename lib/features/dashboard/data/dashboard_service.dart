import 'dart:convert';
import 'package:app/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/dashboard_model.dart';

class DashboardService {
  final String _baseUrl = ApiConstants.baseUrl;

  Future<DashboardResponse?> getDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('session');

      if (session == null) {
        throw Exception('No session found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile/detail'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': session, // Send the session cookie
        },
      );

      if (response.statusCode == 200) {
        final dashboardResponse = DashboardResponse.fromJson(
          jsonDecode(response.body),
        );
        await prefs.setBool('is_premium', dashboardResponse.user.isPremium);
        return dashboardResponse;
      } else {
        print('Dashboard error: ${response.statusCode} - ${response.body}');
        return null; // Or throw specific error
      }
    } catch (e) {
      print('Dashboard service error: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'package:app/core/constants/api_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;
  final String _baseUrl = ApiConstants.baseUrl;

  Future<bool> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        await _googleSignIn.initialize(
          serverClientId:
              '927004603318-jc9ooup1oi21f3019gn65m60nn1minfs.apps.googleusercontent.com',
        );
        _isInitialized = true;
      }
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return false; // Error getting token
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        // Extract session cookie
        // Debugging
        print('Headers: ${response.headers}');
        String? rawCookie = response.headers['set-cookie'];
        print('Found rawCookie: $rawCookie');

        if (rawCookie != null) {
          await _saveSession(rawCookie); // Ensure we await this
        } else {
          print('Warning: No set-cookie header found');
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> _saveSession(String rawCookie) async {
    // Basic parsing to find "session=..."
    // If rawCookie contains "session=xyz;", we want to save that.

    // Simplest approach: Save the whole Set-Cookie header value and use it as Cookie header later.
    // Ideally we should parse it properly.

    final prefs = await SharedPreferences.getInstance();
    // We will save the entire cookie string to be used in the 'Cookie' header for subsequent requests
    await prefs.setString('session', rawCookie);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString('session');
    print('Checking isLoggedIn: session=$session');
    return session != null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
  }
}

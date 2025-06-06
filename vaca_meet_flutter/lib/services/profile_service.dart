import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl = 'https://mobile.vaca-meet.fr/api/mobile/user';

  Future<Map<String, dynamic>> getFullProfile() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération du profil');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMobileProfile(String firstName, String lastName) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTheme(String theme) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/update-theme'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'theme': theme,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du thème');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du mot de passe');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
} 
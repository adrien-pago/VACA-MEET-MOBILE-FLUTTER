import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityCampingService {
  final String baseUrl = 'https://mobile.vaca-meet.fr/api/mobile/camping/info';

  Future<Map<String, dynamic>?> getCampingInfo(int campingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token JWT manquant');
      }
      final url = Uri.parse('$baseUrl/$campingId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
} 
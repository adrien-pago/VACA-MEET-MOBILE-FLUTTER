import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityCampingService {
  final String baseUrl = 'https://mobile.vaca-meet.fr/api/mobile/camping';

  Future<List<Map<String, dynamic>>> getActivities(int campingId, {required DateTime weekStart, required DateTime weekEnd}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token JWT manquant');
      }
      final startStr = "${weekStart.year.toString().padLeft(4, '0')}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}";
      final endStr = "${weekEnd.year.toString().padLeft(4, '0')}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}";
      final url = Uri.parse('$baseUrl/$campingId/activities?start=$startStr&end=$endStr');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['activities'] is List) {
          return List<Map<String, dynamic>>.from(data['activities']);
        } else {
          throw Exception('Format de réponse inattendu');
        }
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
} 
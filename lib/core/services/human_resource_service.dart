import 'dart:convert';
import 'package:http/http.dart' as http;

class HumanResourceService {
  final String baseUrl;

  HumanResourceService({this.baseUrl = "http://localhost:3001/api"});

  // =========================
  // GET all HR
  // =========================
  Future<List<dynamic>> getHR() async {
    final response = await http.get(Uri.parse("$baseUrl/human-resources"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch HR: ${response.body}");
    }
  }

  // =========================
  // ADD HR
  // =========================
  Future<Map<String, dynamic>> addHR(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/human-resources"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add HR: ${response.body}");
    }
  }

  // =========================
  // UPDATE HR
  // =========================
  Future<Map<String, dynamic>> updateHR(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/human-resources/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update HR: ${response.body}");
    }
  }

  // =========================
  // DELETE HR
  // =========================
  Future<Map<String, dynamic>> deleteHR(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/human-resources/$id"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to delete HR: ${response.body}");
    }
  }
}

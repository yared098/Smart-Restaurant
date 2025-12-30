import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfigService {
  final String baseUrl;

  ConfigService({this.baseUrl = "http://localhost:3000/api/config"});

  /// Fetch config from backend
  Future<Map<String, dynamic>> fetchConfig() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("config data is ");
      print(data['config']);
      return data['config'] ?? {};
    } else {
      throw Exception("Failed to fetch config: ${response.statusCode}");
    }
  }

  /// Update config in backend
  Future<Map<String, dynamic>> updateConfig(Map<String, dynamic> updates) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['config'] ?? {};
    } else {
      throw Exception("Failed to update config: ${response.statusCode}");
    }
  }
}

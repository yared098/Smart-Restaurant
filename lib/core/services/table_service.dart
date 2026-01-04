import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table_model.dart';

class TableService {
  final String baseUrl;
  final String? token;

  TableService({this.baseUrl = "http://localhost:3000/api/tables", this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // =========================
  // GET all tables
  // =========================
  Future<List<RestaurantTable>> getTables() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => RestaurantTable.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch tables: ${response.body}");
    }
  }

  // =========================
  // CREATE tables
  // =========================
  Future<List<RestaurantTable>> createTables(int totalTables) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: jsonEncode({"totalTables": totalTables}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => RestaurantTable.fromJson(e)).toList();
    } else {
      print(response.body);
      throw Exception("Failed to create tables: ${response.body}");
    }
  }

  // =========================
  // ASSIGN waiter
  // =========================
  Future<RestaurantTable> assignWaiter(String tableId, String waiterId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$tableId/assign-waiter"),
      headers: _headers,
      body: jsonEncode({"waiterId": waiterId}),
    );

    if (response.statusCode == 200) {
      return RestaurantTable.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to assign waiter: ${response.body}");
    }
  }

  // =========================
  // UNASSIGN waiter
  // =========================
  Future<RestaurantTable> unassignWaiter(String tableId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$tableId/unassign-waiter"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return RestaurantTable.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to unassign waiter: ${response.body}");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ResourceService {
  // Use your LAN IP if testing on a physical device, or 10.0.2.2 for Android Emulator
  final String baseUrl;

  ResourceService({this.baseUrl = "http://localhost:3001/api"});

  // =========================
  // GET all resources
  // =========================
  Future<List<dynamic>> getResources() async {
    final response = await http.get(Uri.parse("$baseUrl/resources"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch resources: ${response.body}");
    }
  }

  // =========================
  // ADD a resource
  // =========================
  Future<Map<String, dynamic>> addResource(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resources"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add resource: ${response.body}");
    }
  }

  // =========================
  // UPDATE a resource
  // =========================
  Future<Map<String, dynamic>> updateResource(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/resources/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update resource: ${response.body}");
    }
  }

  // =========================
  // DELETE a resource
  // =========================
  Future<Map<String, dynamic>> deleteResource(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/resources/$id"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to delete resource: ${response.body}");
    }
  }

  // =========================
  // CREATE a kitchen request
  // =========================
  Future<Map<String, dynamic>> createResourceRequest(
      List<Map<String, dynamic>> items, {String note = ""}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resource-requests"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"items": items, "note": note}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create request: ${response.body}");
    }
  }

  // =========================
  // GET all requests
  // =========================
  Future<List<dynamic>> getResourceRequests() async {
    final response = await http.get(
      Uri.parse("$baseUrl/resource-requests"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch requests: ${response.body}");
    }
  }

  // =========================
  // APPROVE a request
  // =========================
  Future<Map<String, dynamic>> approveRequest(String requestId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resource-requests/$requestId/approve"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to approve request: ${response.body}");
    }
  }

  // =========================
  // REJECT a request
  // =========================
  Future<Map<String, dynamic>> rejectRequest(String requestId, {String reason = ""}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resource-requests/$requestId/reject"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"reason": reason}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to reject request: ${response.body}");
    }
  }
}

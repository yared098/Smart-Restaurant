import 'package:flutter/material.dart';
import '../services/resource_service.dart';

class ResourceProvider extends ChangeNotifier {
  final ResourceService _service = ResourceService();

  // =========================
  // RESOURCE STATE
  // =========================
  List<Map<String, dynamic>> resources = [];
  bool loading = false;

  // =========================
  // REQUEST STATE
  // =========================
  List<Map<String, dynamic>> requests = [];

  // =========================
  // FETCH ALL RESOURCES
  // =========================
  Future<void> fetchResources() async {
    loading = true;
    notifyListeners();
    try {
      final res = await _service.getResources();
      resources = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error fetching resources: $e");
    }
    loading = false;
    notifyListeners();
  }

  // =========================
  // ADD RESOURCE
  // =========================
  Future<void> addResource(Map<String, dynamic> data) async {
    try {
      final newRes = await _service.addResource(data);
      resources.add(Map<String, dynamic>.from(newRes));
      notifyListeners();
    } catch (e) {
      print("Error adding resource: $e");
      rethrow;
    }
  }

  // =========================
  // UPDATE RESOURCE
  // =========================
  Future<void> updateResource(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _service.updateResource(id, data);
      final index = resources.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        resources[index] = Map<String, dynamic>.from(updated);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating resource: $e");
      rethrow;
    }
  }

  // =========================
  // DELETE RESOURCE
  // =========================
  Future<void> deleteResource(String id) async {
    try {
      await _service.deleteResource(id);
      resources.removeWhere((r) => r['id'] == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting resource: $e");
      rethrow;
    }
  }

  // =========================
  // FETCH ALL RESOURCE REQUESTS
  // =========================
  Future<void> fetchRequests() async {
    loading = true;
    notifyListeners();
    try {
      final res = await _service.getResourceRequests();
      requests = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error fetching requests: $e");
    }
    loading = false;
    notifyListeners();
  }

  // =========================
  // CREATE A RESOURCE REQUEST
  // =========================
  Future<void> createRequest(List<Map<String, dynamic>> items, {String note = ""}) async {
    try {
      final newReq = await _service.createResourceRequest(items, note: note);
      requests.add(Map<String, dynamic>.from(newReq['request']));
      notifyListeners();
    } catch (e) {
      print("Error creating request: $e");
      rethrow;
    }
  }

  // =========================
  // APPROVE A REQUEST
  // =========================
  Future<void> approveRequest(String requestId) async {
    try {
      final updated = await _service.approveRequest(requestId);
      final index = requests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        requests[index] = Map<String, dynamic>.from(updated);
        notifyListeners();
      }
    } catch (e) {
      print("Error approving request: $e");
      rethrow;
    }
  }

  // =========================
  // REJECT A REQUEST
  // =========================
  Future<void> rejectRequest(String requestId, {String reason = ""}) async {
    try {
      final updated = await _service.rejectRequest(requestId, reason: reason);
      final index = requests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        requests[index] = Map<String, dynamic>.from(updated);
        notifyListeners();
      }
    } catch (e) {
      print("Error rejecting request: $e");
      rethrow;
    }
  }
}

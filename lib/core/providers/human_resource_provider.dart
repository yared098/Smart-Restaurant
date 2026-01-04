import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/services/human_resource_service.dart';
import 'auth_provider.dart';

class HumanResourceProvider extends ChangeNotifier {
  late HumanResourceService _service;
  final AuthProvider authProvider;

  HumanResourceProvider({required this.authProvider}) {
    _service = HumanResourceService(token: authProvider.token);
  }

  bool loading = false;
  List<dynamic> hrList = [];

  // =========================
  // Fetch HR
  // =========================
  Future<void> fetchHR() async {
    loading = true;
    notifyListeners();
    try {
      _service = HumanResourceService(token: authProvider.token); // refresh token
      hrList = await _service.getHR();
    } catch (e) {
      hrList = [];
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // Add HR
  // =========================
  Future<void> addHR(Map<String, dynamic> data) async {
    loading = true;
    notifyListeners();
    try {
      _service = HumanResourceService(token: authProvider.token);
      final newHR = await _service.addHR(data);
      hrList.add(newHR);
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // Update HR
  // =========================
  Future<void> updateHR(String id, Map<String, dynamic> data) async {
    loading = true;
    notifyListeners();
    try {
      _service = HumanResourceService(token: authProvider.token);
      final updatedHR = await _service.updateHR(id, data);
      final index = hrList.indexWhere((e) => e['id'] == id);
      if (index != -1) hrList[index] = updatedHR;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // Delete HR
  // =========================
  Future<void> deleteHR(String id) async {
    loading = true;
    notifyListeners();
    try {
      _service = HumanResourceService(token: authProvider.token);
      await _service.deleteHR(id);
      hrList.removeWhere((e) => e['id'] == id);
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

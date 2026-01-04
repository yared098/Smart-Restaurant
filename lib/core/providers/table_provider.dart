import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../services/table_service.dart';
import 'auth_provider.dart';

class TableProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  late TableService _service;

  TableProvider({required this.authProvider}) {
    _service = TableService(token: authProvider.token);
  }

  bool loading = false;
  List<RestaurantTable> tables = [];

  // =========================
  // Refresh token in service
  // =========================
  void refreshToken() {
    _service = TableService(token: authProvider.token);
  }

  // =========================
  // GET tables
  // =========================
  Future<void> fetchTables() async {
    if (!authProvider.isLoggedIn) return;

    loading = true;
    notifyListeners();

    try {
      _service = TableService(token: authProvider.token); // refresh token
      tables = await _service.getTables();
    } catch (e) {
      tables = [];
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // CREATE tables
  // =========================
  Future<void> createTables(int totalTables) async {
    if (!authProvider.isLoggedIn) return;

    loading = true;
    notifyListeners();

    try {
      _service = TableService(token: authProvider.token);
      final newTables = await _service.createTables(totalTables);
      tables.addAll(newTables);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // ASSIGN waiter
  // =========================
  Future<void> assignWaiter(String tableId, String waiterId) async {
    if (!authProvider.isLoggedIn) return;

    loading = true;
    notifyListeners();

    try {
      _service = TableService(token: authProvider.token);
      final updatedTable = await _service.assignWaiter(tableId, waiterId);
      final index = tables.indexWhere((t) => t.id == tableId);
      if (index != -1) tables[index] = updatedTable;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // UNASSIGN waiter
  // =========================
  Future<void> unassignWaiter(String tableId) async {
    if (!authProvider.isLoggedIn) return;

    loading = true;
    notifyListeners();

    try {
      _service = TableService(token: authProvider.token);
      final updatedTable = await _service.unassignWaiter(tableId);
      final index = tables.indexWhere((t) => t.id == tableId);
      if (index != -1) tables[index] = updatedTable;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

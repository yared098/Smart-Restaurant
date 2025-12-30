import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/socket_service.dart';

class OrderProvider with ChangeNotifier {
  final SocketService socketService;

  OrderProvider({required this.socketService});

  List<Order> _orders = [];
  List<Order> _orderHistory = [];

  List<Order> get orders => _orders;
  List<Order> get orderHistory => _orderHistory;

  /// Initialize provider: fetch history and listen to socket
  Future<void> init(String restaurantId) async {
    await fetchOrderHistory(restaurantId);
    _listenToNewOrders();
  }

  /// Fetch order history from API
  Future<void> fetchOrderHistory(String restaurantId) async {
    try {
      final fetchedOrders = await socketService.fetchOrders();
      final historyOrders = fetchedOrders.map((json) => Order.fromJson(json)).toList();

      // Avoid duplicates in _orderHistory
      _orderHistory = historyOrders;

      // Also add orders to live _orders if not already there
      for (var order in _orderHistory) {
        addOrder(order); // use existing deduplicated addOrder
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching order history: $e");
    }
  }

  /// Listen to real-time orders from socket
  void _listenToNewOrders() {
    socketService.onNewOrder((data) {
      addOrderFromJson(data['order']);
    });
  }

  /// Add a new live order if it doesn't exist
  void addOrder(Order order) {
    if (!_orders.any((o) => o.id == order.id)) {
      _orders.add(order);
      notifyListeners();
    }
  }

  /// ✅ Add order directly from JSON
  void addOrderFromJson(Map<String, dynamic> json) {
    final order = Order.fromJson(json);
    addOrder(order); // deduplicated
  }

  /// Update an order's status
  void updateOrder(Order order) {
    int index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
      notifyListeners();
    }
  }

  /// Complete an order and move to history
  void completeOrder(String orderId) {
    int index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final completedOrder = _orders.removeAt(index);
      _orderHistory.add(completedOrder);
      notifyListeners();
    }
  }
}

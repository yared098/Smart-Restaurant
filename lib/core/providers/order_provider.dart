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

  Future<void> init(String restaurantId) async {
    await fetchOrderHistory(restaurantId);
    _listenToNewOrders();
    _listenToCategoryOrders();
  }

  Future<void> fetchOrderHistory(String restaurantId) async {
    try {
      final fetchedOrders = await socketService.fetchOrders();
      final historyOrders =
          fetchedOrders.map((json) => Order.fromJson(json)).toList();

      _orderHistory = historyOrders;
      for (var order in _orderHistory) addOrder(order);

      notifyListeners();
    } catch (e) {
      print("Error fetching order history: $e");
    }
  }

  void _listenToNewOrders() {
    socketService.onNewOrder((data) {
      addOrderFromJson(data['order']);
    });
  }

  void _listenToCategoryOrders() {
    socketService.socket.on("new_order_categories", (data) {
      // Optional: category-wise UI updates
      print("Category-wise orders update: $data");
    });
  }

  void addOrder(Order order) {
    if (!_orders.any((o) => o.id == order.id)) {
      _orders.add(order);
      notifyListeners();
    }
  }

  void addOrderFromJson(Map<String, dynamic> json) {
    final order = Order.fromJson(json);
    addOrder(order);
  }

  void updateOrder(Order order) {
    int index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
      notifyListeners();
    }
  }

  void completeOrder(String orderId) {
    int index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final completedOrder = _orders.removeAt(index);
      _orderHistory.add(completedOrder);
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:smart_restaurant/core/services/notification_service.dart';
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
   
    _listenToNewOrders();
    _listenToCategoryOrders();
  }

 

  void _listenToNewOrders() {
    socketService.onNewOrder((data) {
      // Show notification
  NotificationService.showNotification(
    title: "New Order",
    body: "Order #${data['id'] ?? ''} has been placed",
  );
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

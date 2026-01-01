import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_restaurant/core/services/kitchen_service.dart';
import '../models/order.dart';
import 'package:uuid/uuid.dart';

enum SocketStatus { connected, disconnected }
enum NetworkStatus { online, offline }

class KitchenProvider with ChangeNotifier {
  final KitchenService kitchenService;
  final _uuid = const Uuid();

  KitchenProvider({required this.kitchenService}) {
    _startNetworkCheck();
  }

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  // --- Socket status ---
  SocketStatus _socketStatus = SocketStatus.disconnected;
  SocketStatus get socketStatus => _socketStatus;

  void _setSocketStatus(SocketStatus status) {
    _socketStatus = status;
    notifyListeners();
  }

  // --- Network status ---
  NetworkStatus _networkStatus = NetworkStatus.online;
  NetworkStatus get networkStatus => _networkStatus;

  void _setNetworkStatus(NetworkStatus status) {
    _networkStatus = status;
    notifyListeners();
  }

  Timer? _networkTimer;

  void _startNetworkCheck() {
    // check every 5 seconds
    _networkTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _setNetworkStatus(NetworkStatus.online);
        } else {
          _setNetworkStatus(NetworkStatus.offline);
        }
      } catch (_) {
        _setNetworkStatus(NetworkStatus.offline);
      }
    });
  }

  void disposeProvider() {
    _networkTimer?.cancel();
  }

  /// Initialize: join restaurant + listen to events
  void init(String restaurantId) {
    // Track socket connection
    kitchenService.onConnect(() => _setSocketStatus(SocketStatus.connected));
    kitchenService.onDisconnect(() => _setSocketStatus(SocketStatus.disconnected));

    // Listen real-time order events
    kitchenService.onNewOrder((data) => addOrderFromJson(data));
    kitchenService.onUpdateOrder((data) => updateOrderFromJson(data));
    kitchenService.onDeleteOrder((data) => removeOrder(data['orderId']));

    // Load existing orders
    kitchenService.listOrders((res) {
      if (res['success'] == true) {
        for (final o in res['orders']) {
          addOrderFromJson(o);
        }
      }
    });
  }

  /// Add order if not exists
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

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final oldStatus = _orders[index].status;

    // optimistic UI update
    _orders[index] = _orders[index].copyWith(status: newStatus);
    notifyListeners();

    kitchenService.updateOrder(
      {
        "orderId": orderId,
        "updates": {"status": newStatus},
      },
      callback: (res) {
        if (res == null || res['success'] != true) {
          print("❌ Update failed → rollback");
          _orders[index] = _orders[index].copyWith(status: oldStatus);
          notifyListeners();
        } else {
          if (res['order'] != null) {
            _orders[index] = Order.fromJson(res['order']);
            notifyListeners();
          }
          print("✅ Order updated on backend");
        }
      },
    );
  }

  void updateOrderFromJson(Map<String, dynamic> json) {
    final index = _orders.indexWhere((o) => o.id == json['id']);
    if (index != -1) {
      _orders[index] = Order.fromJson(json);
      notifyListeners();
    }
  }

  void removeOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  Future<bool> createKitchenOrder({
    required List<OrderItem> items,
    required String personName,
  }) async {
    if (items.isEmpty || personName.isEmpty) return false;

    final completer = Completer<bool>();

    kitchenService.createOrder(
      {
        "items": items.map((e) => e.toJson()).toList(),
        "receiver": personName,
        "table": "Kitchen",
      },
      callback: (response) {
        if (response == null) {
          completer.complete(false);
          return;
        }

        final success = response['success'] == true;

        if (success && response['order'] != null) {
          addOrderFromJson(response['order']);
        }

        completer.complete(success);
      },
    );

    return completer.future;
  }

  void deleteOrder(String restaurantId, String orderId) {
    // kitchenService.deleteOrder(restaurantId, orderId);
  }
}

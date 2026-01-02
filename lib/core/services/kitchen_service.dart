import 'package:socket_io_client/socket_io_client.dart' as IO;

class KitchenService {
  late final IO.Socket socket;
  final String baseUrl;

  KitchenService({this.baseUrl = "http://localhost:3001"}) {
    _connect();
  }

  void _connect() {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(3000)
          .build(),
    );

    socket.connect();

    // Socket connection events
    socket.onConnect((_) {
      print("✅ Connected to backend");
      if (_onConnectCallback != null) _onConnectCallback!();
    });

    socket.onDisconnect((_) {
      print("🔴 Disconnected from backend");
      if (_onDisconnectCallback != null) _onDisconnectCallback!();
    });

    socket.onConnectError((err) {
      print("⚠️ Connection error: $err");
    });

    socket.onError((err) {
      print("⚠️ Socket error: $err");
    });
  }

  // --- Callbacks for Provider ---
  Function()? _onConnectCallback;
  Function()? _onDisconnectCallback;

  void onConnect(Function() callback) {
    _onConnectCallback = callback;
  }

  void onDisconnect(Function() callback) {
    _onDisconnectCallback = callback;
  }

  // --- Order events ---
  void onNewOrder(Function(dynamic) callback) {
    socket.on("new_order", callback);
  }

  void onUpdateOrder(Function(dynamic) callback) {
    socket.on("update_order", callback);
  }

  void onDeleteOrder(Function(dynamic) callback) {
    socket.on("delete_order", callback);
  }

  void onCategoryOrders(Function(dynamic) callback) {
    socket.on("new_order_categories", callback);
    socket.on("update_order_categories", callback);
  }

  // --- Emit events ---
  void createOrder(Map<String, dynamic> orderData, {Function(dynamic)? callback}) {
    socket.emitWithAck("create_order", orderData, ack: callback);
  }

  void updateOrder(Map<String, dynamic> orderData, {Function(dynamic)? callback}) {
    socket.emitWithAck("update_order", orderData, ack: callback);
  }

  void deleteOrder(String orderId, {Function(dynamic)? callback}) {
    socket.emitWithAck("delete_order", {"orderId": orderId}, ack: callback);
  }

  void listOrders(Function(dynamic) callback) {
    socket.emitWithAck("list_orders", {}, ack: callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}

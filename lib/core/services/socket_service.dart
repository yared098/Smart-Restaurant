import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:http/http.dart' as http;

class SocketService {
  late IO.Socket socket;
  final String baseUrl;

  SocketService({this.baseUrl = "http://localhost:3001/api"});

  /// Connect to socket server
  void connect() {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.connect();
  }

  /// Listen to new orders in real-time
  void onNewOrder(Function(dynamic) callback) {
    socket.on("new_order", callback);
  }

  /// Listen to menu updates in real-time
  void onMenuUpdate(Function(dynamic) callback) {
    socket.on("menu_updated", callback);
  }

  /// Disconnect from socket
  void disconnect() {
    socket.disconnect();
  }

 
}

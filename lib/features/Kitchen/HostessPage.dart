import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/models/order.dart';
import 'package:smart_restaurant/core/providers/kitchen_provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';

class HostessPage extends StatefulWidget {
  const HostessPage({super.key});

  @override
  State<HostessPage> createState() => _HostessPageState();
}

class _HostessPageState extends State<HostessPage> {
  String searchText = "";
  Order? selectedOrder;

  @override
  void initState() {
    super.initState();
    final kitchenProvider = context.read<KitchenProvider>();
    kitchenProvider.init("restaurantId"); // Replace with real restaurantId
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final primaryColor = config.primaryColor ?? Colors.blue;
    final secondaryColor = config.secondaryColor ?? Colors.orange;

    final orders = context.watch<KitchenProvider>().orders;

    final filteredOrders = orders.where((o) {
      return o.receiver.toLowerCase().contains(searchText.toLowerCase()) ||
          o.items.any((item) => item.name.toLowerCase().contains(searchText.toLowerCase()));
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Hostess Dashboard"),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onChanged: (v) => setState(() => searchText = v),
                  decoration: InputDecoration(
                    hintText: "Search orders...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // Orders list
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Center(child: Text("No orders found"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: filteredOrders.length,
                        itemBuilder: (_, i) {
                          final o = filteredOrders[i];
                          final color = _statusColor(o.status, primaryColor, secondaryColor);

                          return GestureDetector(
                            onTap: () => setState(() => selectedOrder = o),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.2),
                                    color.withOpacity(0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(color: color, width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Receiver + Status + Time Ago
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Table / Receiver: ${o.receiver}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: color.shade800,
                                              ),
                                            ),
                                            if (o.updatedAt != null)
                                              Text(
                                                timeAgo(o.updatedAt!),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          o.status,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Items small cards
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: o.items.map((item) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(item.name, style: const TextStyle(fontSize: 12)),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text("x${item.quantity}",
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 11)),
                                            ),
                                            const SizedBox(width: 4),
                                            Text("${item.price} ETB", style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  // Total
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Total: ${o.total} ETB",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // Detail panel
          if (selectedOrder != null) _orderDetailPanel(selectedOrder!, primaryColor, secondaryColor)
        ],
      ),
    );
  }

  MaterialColor _statusColor(String status, Color primary, Color secondary) {
    switch (status) {
      case "NEW":
        return primary is MaterialColor ? primary : Colors.green;
      case "COOKING":
        return secondary is MaterialColor ? secondary : Colors.orange;
      case "ON THE WAY":
        return Colors.blue;
      case "DONE":
        return Colors.grey;
      case "REJECTED":
        return Colors.red;
      default:
        return primary is MaterialColor ? primary : Colors.blue;
    }
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} h ago";
    if (diff.inDays < 7) return "${diff.inDays} d ago";
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _orderDetailPanel(Order order, Color primary, Color secondary) {
    final color = _statusColor(order.status, primary, secondary);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: 0,
      bottom: 0,
      right: 0,
      left: 120,
      child: Material(
        elevation: 14,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text("Order Details",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => selectedOrder = null))
                ],
              ),
              const Divider(),
              Text("Table / Receiver: ${order.receiver}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (order.updatedAt != null)
                Text(timeAgo(order.updatedAt!),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              // Status dropdown using provider
              Row(
                children: [
                  const Text("Change Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: order.status,
                    items: ["NEW", "COOKING", "ON THE WAY", "DONE", "REJECTED"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context.read<KitchenProvider>().updateOrderStatus(order.id, v);
                        setState(() {
                          selectedOrder = order.copyWith(status: v, updatedAt: DateTime.now());
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 14)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("x${item.quantity}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 6),
                          Text("${item.price} ETB",
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              Text("Total: ${order.total} ETB",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

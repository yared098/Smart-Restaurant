import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/kitchen_provider.dart';
import '../../core/models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> statuses = ["NEW", "COOKING", "ON THE WAY", "DONE", "REJECTED"];

  @override
  void initState() {
    super.initState();
    final kitchenProvider = context.read<KitchenProvider>();
    kitchenProvider.init("restaurantId"); // replace with real restaurantId
    _tabController = TabController(length: statuses.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final kitchenProvider = context.watch<KitchenProvider>();
    final orders = kitchenProvider.orders;
    final socketStatus = kitchenProvider.socketStatus;
    final networkStatus = kitchenProvider.networkStatus;

    // Connection indicator
    Color statusColor;
    if (networkStatus == NetworkStatus.offline) {
      statusColor = Colors.red;
    } else if (socketStatus == SocketStatus.connected) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.orange;
    }

    // Status counts
    final statusCounts = {
      for (var s in statuses) s: orders.where((o) => o.status == s).length
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            const Text("Orders"),
            const SizedBox(width: 10),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            // color: Colors.white.withOpacity(0.3),
          ),
          tabs: statuses.map((status) {
            return Tab(
              child: Row(
                children: [
                  Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  if (statusCounts[status]! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(status).shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusCounts[status]!.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: statuses.map((status) {
          final filteredOrders = orders.where((o) => o.status == status).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Text(
                "No $status orders",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filteredOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final o = filteredOrders[index];
              final color = _statusColor(o.status);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: color.withOpacity(0.4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: color, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Receiver + Status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Table / Receiver: ${o.receiver}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color.shade800),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              o.status,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Items as chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: o.items.map((item) {
                          return Chip(
                            label: Text("${item.name} x${item.quantity}"),
                            backgroundColor: color.withOpacity(0.15),
                            labelStyle: TextStyle(color: color.shade800),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      // Total
                      Text(
                        "Total: ${o.total} ETB",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      // Change Status Dropdown
                      Row(
                        children: [
                          const Text(
                            "Change Status: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: o.status,
                            items: statuses
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                context
                                    .read<KitchenProvider>()
                                    .updateOrderStatus(o.id, val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  MaterialColor _statusColor(String status) {
    switch (status) {
      case "NEW":
        return Colors.green;
      case "COOKING":
        return Colors.orange;
      case "ON THE WAY":
        return Colors.blue;
      case "DONE":
        return Colors.grey;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

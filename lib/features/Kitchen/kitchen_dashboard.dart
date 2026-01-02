import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/models/order.dart';
import 'package:smart_restaurant/core/providers/kitchen_provider.dart';
import 'package:smart_restaurant/core/providers/resource_provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';

enum KitchenTab { Orders, Resources }

class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  KitchenTab currentTab = KitchenTab.Orders;
  String searchText = "";
  Order? selectedOrder;
  Map<String, int> requestCart = {}; // resourceId -> quantity
  Map<String, Map<String, dynamic>> selectedResources = {}; // id -> resource

  @override
  void initState() {
    super.initState();
    final kitchenProvider = context.read<KitchenProvider>();
    kitchenProvider.init("restaurantId"); // Replace with real restaurantId

    final resourceProvider = context.read<ResourceProvider>();
    resourceProvider.fetchResources();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final primaryColor = config.primaryColor ?? Colors.blue;
    final secondaryColor = config.secondaryColor ?? Colors.orange;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text("Kitchen Dashboard"),
            backgroundColor: primaryColor,
            actions: [
              if (!isLargeScreen)
                IconButton(
                  icon: Icon(currentTab == KitchenTab.Orders
                      ? Icons.inventory
                      : Icons.receipt),
                  tooltip: currentTab == KitchenTab.Orders
                      ? "Show Resources"
                      : "Show Orders",
                  onPressed: () {
                    setState(() {
                      currentTab = currentTab == KitchenTab.Orders
                          ? KitchenTab.Resources
                          : KitchenTab.Orders;
                    });
                  },
                )
            ],
          ),
          body: isLargeScreen
              ? Row(
                  children: [
                    Expanded(child: _ordersPanel(primaryColor, secondaryColor)),
                    VerticalDivider(width: 1, color: Colors.grey.shade300),
                    Expanded(child: _resourcesPanel(primaryColor)),
                  ],
                )
              : currentTab == KitchenTab.Orders
                  ? _ordersPanel(primaryColor, secondaryColor)
                  : _resourcesPanel(primaryColor),
        );
      },
    );
  }

  // ------------------ Orders Panel ------------------
  Widget _ordersPanel(Color primaryColor, Color secondaryColor) {
    final orders = context.watch<KitchenProvider>().orders;
    final filteredOrders = orders.where((o) {
      return o.receiver.toLowerCase().contains(searchText.toLowerCase()) ||
          o.items.any(
              (item) => item.name.toLowerCase().contains(searchText.toLowerCase()));
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
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
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                              style: const TextStyle(
                                                  fontSize: 10, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
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
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: o.items.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(item.name, style: const TextStyle(fontSize: 12)),
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text("x${item.quantity}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11)),
                                          ),
                                          const SizedBox(width: 4),
                                          Text("${item.price} ETB",
                                              style: const TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Total: ${o.total} ETB",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
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
        if (selectedOrder != null)
          _orderDetailPanel(selectedOrder!, primaryColor, secondaryColor),
      ],
    );
  }

  // ------------------ Resources Panel ------------------
  Widget _resourcesPanel(Color primaryColor) {
    final provider = context.watch<ResourceProvider>();

    return provider.loading
        ? const Center(child: CircularProgressIndicator())
        : provider.resources.isEmpty
            ? const Center(child: Text("No resources available"))
            : ListView.builder(
                itemCount: provider.resources.length,
                itemBuilder: (_, index) {
                  final res = provider.resources[index];
                  final resId = res['id'] ?? '';
                  final unit = res['unit'] ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: res['imageUrl'] != null && res['imageUrl'].isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                res['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.inventory),
                            ),
                      title: Text(res['name'] ?? ''),
                      subtitle:
                          Text("Available: ${res['quantity'] ?? 0} $unit"),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: requestCart[resId] != null &&
                                      requestCart[resId]! > 0
                                  ? () {
                                      setState(() {
                                        requestCart[resId] = requestCart[resId]! - 1;
                                        if (requestCart[resId] == 0) {
                                          requestCart.remove(resId);
                                          selectedResources.remove(resId);
                                        }
                                      });
                                    }
                                  : null,
                            ),
                            Text(requestCart[resId]?.toString() ?? '0'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  final qty = requestCart[resId] ?? 0;
                                  if (qty < (res['quantity'] ?? 1000)) {
                                    requestCart[resId] = qty + 1;
                                    selectedResources[resId] = res;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  // ------------------ Helpers ------------------
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
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
      ),
    );
  }
}

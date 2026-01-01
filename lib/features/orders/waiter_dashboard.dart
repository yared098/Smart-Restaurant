import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/models/product.dart';
import 'package:smart_restaurant/core/models/order.dart';
import 'package:smart_restaurant/core/providers/product_provider.dart';
import 'package:smart_restaurant/core/providers/kitchen_provider.dart';
import 'package:smart_restaurant/core/services/api_service.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';


class KitchenDashboardPage extends StatefulWidget {
  const KitchenDashboardPage({super.key});

  @override
  State<KitchenDashboardPage> createState() => _KitchenDashboardPageState();
}

class _KitchenDashboardPageState extends State<KitchenDashboardPage> {
  final ApiService api = ApiService();
  final TextEditingController searchCtrl = TextEditingController();

  bool loading = true;
  final Set<Product> selectedProducts = {};
  String searchText = "";

  // Show/hide panels
  bool showProducts = true;
  bool showOrders = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    final kitchenProvider = context.read<KitchenProvider>();
    kitchenProvider.init("restaurantId"); // replace with real restaurantId
  }

  Future<void> _loadProducts() async {
    try {
      final categories = await api.getMenu();
      List<Product> products = [];

      for (var cat in categories) {
        final catName = cat['name'] ?? 'Uncategorized';
        for (var item in cat['items']) {
          products.add(Product.fromJson(item, categoryName: catName));
        }
      }

      context.read<ProductProvider>().setProducts(products);
    } catch (e) {
      debugPrint("❌ Menu load failed: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void _toggleSelect(Product p) {
    setState(() {
      if (selectedProducts.contains(p)) {
        selectedProducts.remove(p);
      } else {
        selectedProducts.add(p);
      }
    });
  }

  Future<void> _createOrder() async {
    if (selectedProducts.isEmpty) return;

    final controller = TextEditingController();
    final receiverName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Receiver Name / Table"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Table or Person Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (receiverName == null || receiverName.isEmpty) return;

    final items = selectedProducts.map((p) {
      return OrderItem(
        name: p.name,
        price: p.price,
        quantity: 1,
        category: p.categoryName,
      );
    }).toList();

    await context.read<KitchenProvider>().createKitchenOrder(
          items: items,
          personName: receiverName,
        );

    setState(() => selectedProducts.clear());
  }

  @override
  Widget build(BuildContext context) {
     final config = context.watch<ConfigProvider>();
    final productsByCategory =
        context.watch<ProductProvider>().productsByCategory;
    final orders = context.watch<KitchenProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: config.primaryColor,
        title: const Text("Waite Dashboard"),
        foregroundColor: Colors.white,
        
        elevation: 0,
        actions: [
          IconButton(
            tooltip: showProducts ? "Hide Products" : "Show Products",
            onPressed: () => setState(() => showProducts = !showProducts),
            icon: Icon(showProducts ? Icons.fastfood : Icons.fastfood_outlined),
          ),
          IconButton(
            tooltip: showOrders ? "Hide Orders" : "Show Orders",
            onPressed: () => setState(() => showOrders = !showOrders),
            icon: Icon(showOrders ? Icons.list_alt : Icons.list_alt_outlined),
          ),
        ],
      ),
     body: loading
    ? const Center(child: CircularProgressIndicator())
    : LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;

          if (isSmallScreen) {
            // Determine which panel to show: prioritize products if both true
            Widget content;
            if (showProducts) {
              content = _buildProducts(productsByCategory);
            } else if (showOrders) {
              content = _buildOrders(orders);
            } else {
              content = const Center(
                child: Text(
                  "Nothing to show. Use top buttons to display panels.",
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: content,
            );
          }

          // Large screen: show both panels if selected
          return Row(
            children: [
              if (showProducts)
                Expanded(flex: 3, child: _buildProducts(productsByCategory)),
              if (showOrders)
                Expanded(flex: 2, child: _buildOrders(orders)),
              if (!showProducts && !showOrders)
                const Expanded(
                  child: Center(
                    child: Text(
                      "Nothing to show. Use top buttons to display panels.",
                    ),
                  ),
                ),
            ],
          );
        },
      ),

    
    );
  }

  /// -----------------------------
  /// PRODUCTS PANEL
  /// -----------------------------
 Widget _buildProducts(Map<String, List<Product>> data) {
  return Container(
    padding: const EdgeInsets.all(12),
    color: Colors.grey.shade50,
    child: Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: searchCtrl,
            onChanged: (v) => setState(() => searchText = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search product...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Product grid
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: data.entries.map((entry) {
                final filtered = entry.value
                    .where((p) => p.name.toLowerCase().contains(searchText))
                    .toList();
                if (filtered.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    LayoutBuilder(builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 1200) crossAxisCount = 5;
                      else if (constraints.maxWidth > 800) crossAxisCount = 4;
                      else if (constraints.maxWidth > 600) crossAxisCount = 3;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (_, i) {
                          final p = filtered[i];
                          final selected = selectedProducts.contains(p);

                          return GestureDetector(
                            onDoubleTap: () => _toggleSelect(p),
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.deepOrange
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Product image
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12)),
                                          child: Image.network(
                                            p.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      // Product info
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Text(
                                              p.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${p.price} ETB",
                                              style: const TextStyle(
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Selected indicator
                                if (selected)
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.deepOrange,
                                      child: Icon(Icons.check,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // Order button
        if (selectedProducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createOrder,
                icon: const Icon(Icons.receipt_long),
                label: Text("Order Now (${selectedProducts.length})"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

  /// -----------------------------
  /// ORDERS PANEL
  /// -----------------------------
 /// -----------------------------
/// ORDERS PANEL
/// -----------------------------
Widget _buildOrders(List<Order> orders) {
  Color statusColor(String status) {
    switch (status) {
      case "NEW":
        return Colors.green.shade400;
      case "COOKING":
        return Colors.orange.shade400;
      case "ON THE WAY":
        return Colors.blue.shade400;
      case "DONE":
        return Colors.grey.shade400;
      case "REJECTED":
        return Colors.red.shade400;
      default:
        return Colors.black26;
    }
  }

  // Sort orders by updatedAt descending (newest first)
  final sortedOrders = List<Order>.from(orders)
    ..sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.now();
      final bTime = b.updatedAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

  return Container(
    padding: const EdgeInsets.all(12),
    color: Colors.grey.shade50,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Incoming Orders",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: sortedOrders.isEmpty
              ? const Center(child: Text("No orders yet"))
              : ListView.builder(
                  itemCount: sortedOrders.length,
                  itemBuilder: (_, i) {
                    final o = sortedOrders[i];
                    final color = statusColor(o.status);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: color, width: 6),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Table / Receiver: ${o.receiver}",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: DropdownButton<String>(
                                    value: o.status,
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "NEW",
                                        child: Text("NEW"),
                                      ),
                                      DropdownMenuItem(
                                        value: "COOKING",
                                        child: Text("COOKING"),
                                      ),
                                      DropdownMenuItem(
                                        value: "ON THE WAY",
                                        child: Text("ON THE WAY"),
                                      ),
                                      DropdownMenuItem(
                                        value: "DONE",
                                        child: Text("DONE"),
                                      ),
                                      DropdownMenuItem(
                                        value: "REJECTED",
                                        child: Text("REJECTED"),
                                      ),
                                    ],
                                    onChanged: (status) {
                                      if (status != null) {
                                        context
                                            .read<KitchenProvider>()
                                            .updateOrderStatus(o.id, status);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: o.items
                                  .map((item) => Text(
                                      "• ${item.name} x${item.quantity} - ${item.price} ETB",
                                      style: const TextStyle(fontSize: 13)))
                                  .toList(),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total: ${o.total} ETB",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                if (o.updatedAt != null)
                                  Text(
                                    "Updated: ${o.updatedAt!.hour.toString().padLeft(2,'0')}:${o.updatedAt!.minute.toString().padLeft(2,'0')}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                              ],
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
  );
}
}

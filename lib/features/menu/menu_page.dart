import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../core/models/product.dart';
import '../../core/models/order.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/services/api_service.dart';

class MenuPage extends StatefulWidget {
  final String restaurantId;

  const MenuPage({super.key, required this.restaurantId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final api = ApiService();
  bool loading = true;
  late TabController _tabController;

  List<Product> _cart = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    final categories = await api.getMenu();
    List<Product> products = [];

    for (var cat in categories) {
      final categoryName = cat['name'] ?? 'Others';
      for (var item in cat['items']) {
        products.add(Product.fromJson(item, categoryName: categoryName));
      }
    }

    Provider.of<ProductProvider>(context, listen: false).setProducts(products);

    final categoryCount = Provider.of<ProductProvider>(context, listen: false)
        .productsByCategory
        .length;

    _tabController = TabController(length: categoryCount, vsync: this);

    setState(() => loading = false);
  }

  void placeOrder() async {
    if (_cart.isEmpty) return;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final orderData = {
      "restaurantId": widget.restaurantId,
      "receiver": "Guest",
      "items": _cart.map((p) => {
            "name": p.name,
            "category": p.categoryName,
            "quantity": p.quantity > 0 ? p.quantity : 1,
            "price": p.price,
          }).toList(),
      "total": _cart.fold<double>(
          0, (sum, p) => sum + ((p.quantity > 0 ? p.quantity : 1) * p.price)),
      "table": "Table ${Random().nextInt(10) + 1}",
    };

    try {
      final Map<String, dynamic> response = await api.createOrder(orderData);

      if (response['success'] == true) {
        final orderJson = response['order'] as Map<String, dynamic>;
        orderProvider.addOrderFromJson(orderJson);

        setState(() {
          _cart.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order placed successfully"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to place order"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error placing order"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// --------------------------
  /// Show Cart in BottomSheet
  /// --------------------------
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your Cart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _cart.isEmpty
                    ? const Text("Your cart is empty")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final p = _cart[index];
                          return ListTile(
                            title: Text(p.name),
                            subtitle: Text(
                                "${p.quantity ?? 1} x ${p.price} ETB = ${(p.quantity ?? 1) * p.price} ETB"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setStateSheet(() {
                                      setState(() {
                                        if ((p.quantity ?? 1) > 1) {
                                          p.quantity = (p.quantity ?? 1) - 1;
                                        } else {
                                          _cart.removeAt(index);
                                        }
                                      });
                                    });
                                  },
                                ),
                                Text("${p.quantity ?? 1}"),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setStateSheet(() {
                                      setState(() {
                                        p.quantity = (p.quantity ?? 1) + 1;
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _cart.isEmpty
                      ? null
                      : () {
                          placeOrder();
                          Navigator.pop(context);
                        },
                  child: const Text("Order Now"),
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsByCategory =
        Provider.of<ProductProvider>(context).productsByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Menu"),
        bottom: loading
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: productsByCategory.keys
                    .map((c) => Tab(text: c))
                    .toList(),
              ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: productsByCategory.entries.map((entry) {
                final items = entry.value;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final p = items[index];
                    return _productTile(p);
                  },
                );
              }).toList(),
            ),
      floatingActionButton: _cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.shopping_cart),
              label: Text("${_cart.length}"),
              onPressed: _showCartBottomSheet,
            ),
    );
  }

  Widget _productTile(Product p) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!_cart.contains(p)) {
            p.quantity = 1;
            _cart.add(p);
          } else {
            p.quantity = (p.quantity ?? 1) + 1;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${p.name} added to cart"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(14)),
              child: Image.network(
                p.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.fastfood, size: 50),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${p.price} ETB",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (!_cart.contains(p)) {
                              p.quantity = 1;
                              _cart.add(p);
                            } else {
                              p.quantity = (p.quantity ?? 1) + 1;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Add to Cart"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

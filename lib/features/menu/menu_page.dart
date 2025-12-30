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

    Provider.of<ProductProvider>(context, listen: false)
        .setProducts(products);

    final categoryCount = Provider.of<ProductProvider>(context, listen: false)
        .productsByCategory
        .length;

    _tabController = TabController(length: categoryCount, vsync: this);

    setState(() => loading = false);
  }

  void placeOrder(Product product) {
    final orderProvider =
        Provider.of<OrderProvider>(context, listen: false);

    api.createOrder({
      "restaurantId": widget.restaurantId,
      "items": [product.name],
      "total": product.price,
      "table": "Table ${Random().nextInt(10) + 1}",
    });

    orderProvider.addOrder(
      Order(
        id: product.id,
        items: [product.name],
        total: product.price,
        table: "Table 1",
        status: "NEW",
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to order"),
        behavior: SnackBarBehavior.floating,
      ),
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
    );
  }

  Widget _productTile(Product p) {
    return Container(
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
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
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
                      onPressed: () => placeOrder(p),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Order"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

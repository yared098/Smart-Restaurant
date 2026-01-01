import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/features/config/ConfigPage.dart';
import 'package:smart_restaurant/features/menu/menu_page.dart';
import 'package:smart_restaurant/features/orders/orders_page.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';

import '../../core/providers/order_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/models/product.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/api_service.dart';
import 'add_product_page.dart';
import 'menu_qr_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final socket = SocketService();
  final api = ApiService();
  bool loadingProducts = true;

  String selectedSection = "Products"; // Sidebar selected item

  Product? selectedProduct;
  bool showProductSlide = false;

  // Search query
  String searchQuery = "";

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    socket.connect();

    socket.onNewOrder((data) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.addOrderFromJson(data['order']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New Order Received!")),
      );
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final categories = await api.getMenu();
      List<Product> products = [];

      for (var cat in categories) {
        final catName = cat['name'] ?? 'Uncategorized';
        for (var item in cat['items']) {
          products.add(Product.fromJson(item, categoryName: catName));
        }
      }

      Provider.of<ProductProvider>(context, listen: false).setProducts(products);
    } catch (e) {
      debugPrint("Error fetching products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch products")),
      );
    } finally {
      setState(() => loadingProducts = false);
    }
  }

  Color orderStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.green.shade100;
      case 'IN_PROGRESS':
        return Colors.yellow.shade100;
      case 'DONE':
        return Colors.grey.shade200;
      default:
        return Colors.white;
    }
  }

 
  Widget buildSidebar(
  Color sidebarColor,
  Color selectedColor,
  String appName,
  String appLogo,
) {
  return Container(
    width: 220,
    color: sidebarColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        // LOGO + APP NAME
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: appLogo.isNotEmpty
                    ? NetworkImage(appLogo)
                    : null,
                child: appLogo.isEmpty
                    ? Icon(Icons.restaurant, color: sidebarColor, size: 30)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        buildSidebarButton(Icons.fastfood, "Products", selectedColor),
        buildSidebarButton(Icons.add, "Add Product", selectedColor),
        buildSidebarButton(Icons.settings, "Config", selectedColor),
        buildSidebarButton(Icons.list_alt, "Incoming Orders", selectedColor),
        buildSidebarButton(Icons.history, "Order History", selectedColor),
        buildSidebarButton(Icons.qr_code, "Menu QR Code", selectedColor),
        buildSidebarButton(Icons.menu, "Menu", selectedColor),

        const Spacer(),

        buildSidebarButton(Icons.logout, "Logout", selectedColor),
        const SizedBox(height: 20),
      ],
    ),
  );
}

  Widget buildSidebarButton(
  IconData icon,
  String label,
  Color selectedColor,
) {
  bool isSelected = selectedSection == label;

  return InkWell(
    onTap: () {
      setState(() {
        selectedSection = label;
        showProductSlide = false;
      });
    },
    child: Container(
      color: isSelected ? selectedColor : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}


  void openProductSlide(Product p) {
    setState(() {
      selectedProduct = p;
      nameController.text = p.name;
      priceController.text = p.price.toString();
      imageController.text = p.imageUrl;
      showProductSlide = true;
    });
  }

  void deleteProduct(Product p) async {
    try {
      await api.deleteProduct(p.id);
      Provider.of<ProductProvider>(context, listen: false).removeProduct(p.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully")),
      );
      setState(() => showProductSlide = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete product")),
      );
    }
  }

  void updateProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;
    final updated = Product(
      id: selectedProduct!.id,
      name: nameController.text,
      price: double.parse(priceController.text),
      imageUrl: imageController.text,
      categoryId: selectedProduct!.categoryId,
      categoryName: selectedProduct!.categoryName,
    );

    try {
      await api.updateProduct({
        "id": updated.id,
        "name": updated.name,
        "price": updated.price,
        "imageUrl": updated.imageUrl,
        "categoryId": updated.categoryId,
      });

      Provider.of<ProductProvider>(context, listen: false).updateProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );
      setState(() => showProductSlide = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update product")),
      );
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();

  final Color sidebarColor =
      config.primaryColor ?? Colors.blue.shade700;

  final Color selectedColor =
      config.secondaryColor ?? Colors.blue.shade900;

  final String appName =
      config.appName ?? "Admin Panel";

  final String appLogo =
      config.appLogo;

    return Scaffold(
      body: Row(
        children: [
          // buildSidebar(),
          buildSidebar(
      sidebarColor,
      selectedColor,
      appName,
      appLogo,
    ),
          Expanded(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      buildMainContent(),
                      if (showProductSlide) buildProductSlide(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainContent() {
    final productsByCategory =
        Provider.of<ProductProvider>(context).productsByCategory;
    final orders = Provider.of<OrderProvider>(context).orders;
    final orderHistory = Provider.of<OrderProvider>(context).orderHistory;

    if (loadingProducts) return const Center(child: CircularProgressIndicator());

    switch (selectedSection) {
      case "Products":
        return buildProductsView(productsByCategory);
      case "Menu":
  return MenuPage(
    restaurantId: "rest_001", // same ID used for QR
  );
      case "Add Product":
        return const Padding(
          padding: EdgeInsets.all(16),
          child: AddProductPanel(),
        );
        case  "Config":
        return const Padding(
          padding: EdgeInsets.all(16),
          child: ConfigPage(),
        );

      case "Incoming Orders":
        return buildOrdersView(orders, "Incoming Orders");
      case "Order History":
        // return buildOrdersView(orderHistory, "Order History");
        return const Padding(padding: EdgeInsets.all(16),child: OrdersPage(),);

      case "Menu QR Code":
        return Padding(
          padding: const EdgeInsets.all(16),
          child: MenuQRCodePage(
            restaurantId: "rest_001",
            restaurantName: "My Restaurant",
          ),
        );
      default:
        return Center(
          child: Text(
            selectedSection,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  Widget buildProductsView(Map<String, List<Product>> productsByCategory) {
    if (productsByCategory.isEmpty)
      return const Center(child: Text("No products available"));

    // Filter products based on search query
    Map<String, List<Product>> filtered = {};
    productsByCategory.forEach((category, items) {
      final filteredItems = items
          .where((p) => p.name.toLowerCase().contains(searchQuery))
          .toList();
      if (filteredItems.isNotEmpty) filtered[category] = filteredItems;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: filtered.entries.map((entry) {
          final categoryName = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final p = items[index];
                  return GestureDetector(
                    onDoubleTap: () => openProductSlide(p),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                p.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              children: [
                                Text(
                                  p.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "\$${p.price.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildProductSlide() {
    if (selectedProduct == null) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: MediaQuery.of(context).size.width * 0.4,
      child: Material(
        elevation: 10,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () => setState(() => showProductSlide = false),
                      icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(selectedProduct!.imageUrl,
                    height: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: inputDecoration("Product Name"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: inputDecoration("Price"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: imageController,
                decoration: inputDecoration("Image URL"),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.update),
                      label: const Text("Update"),
                      onPressed: updateProduct,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => deleteProduct(selectedProduct!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrdersView(List orders, String title) {
    if (orders.isEmpty) return Center(child: Text("No $title"));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: orders.map<Widget>((o) {
          return Card(
            color: orderStatusColor(o.status),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text("Table: ${o.table}"),
              subtitle: Text("Items: ${o.items.join(", ")}\nStatus: ${o.status}"),
            ),
          );
        }).toList(),
      ),
    );
  }
}

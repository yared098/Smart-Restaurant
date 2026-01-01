import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';
import '../../core/models/product.dart';
import '../../core/providers/product_provider.dart';
import '../../core/services/api_service.dart';

class AddProductPanel extends StatefulWidget {
  const AddProductPanel({super.key});

  @override
  State<AddProductPanel> createState() => _AddProductPanelState();
}

class _AddProductPanelState extends State<AddProductPanel> with SingleTickerProviderStateMixin {
  final _productFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();
  final api = ApiService();

  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  String? selectedCategoryId;
  String? selectedCategoryName;

  // Category BottomSheet form
  final _categoryFormKey = GlobalKey<FormState>();
  final categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);
    try {
      final fetchedCategories = await api.getCategories();
      setState(() {
        categories = List<Map<String, dynamic>>.from(fetchedCategories);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load categories")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    categoryNameController.dispose();
    super.dispose();
  }

  void submitProduct() async {
    if (_productFormKey.currentState!.validate() && selectedCategoryId != null) {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        price: double.parse(priceController.text),
        imageUrl: imageController.text,
        categoryId: selectedCategoryId!,
        categoryName: selectedCategoryName!,
      );

      Provider.of<ProductProvider>(context, listen: false).addProduct(product);

      try {
        await api.addProduct({
          "restaurantId": "rest_001",
          "categoryId": selectedCategoryId!,
          "name": product.name,
          "price": product.price,
          "imageUrl": product.imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product Added!")),
        );

        // Clear form
        nameController.clear();
        priceController.clear();
        imageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product")),
        );
      }
    }
  }

  void submitCategory() async {
    if (_categoryFormKey.currentState!.validate()) {
      final newCategory = {"name": categoryNameController.text};

      try {
        await api.addCategory(newCategory);
        categoryNameController.clear();

        Navigator.pop(context);
        await fetchCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category Added!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add category")),
        );
      }
    }
  }

  InputDecoration inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon) : null,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  void showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Form(
          key: _categoryFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add New Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: categoryNameController,
                decoration: inputDecoration("Category Name", icon: Icons.category),
                validator: (val) => val == null || val.isEmpty ? "Enter category name" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed: submitCategory,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  final config = Provider.of<ConfigProvider>(context);

  final primary = config.primaryColor ?? Colors.black;
  final secondary = config.secondaryColor ?? Colors.blue;

  return Scaffold(
    appBar: AppBar(
      title: Text(config.appName ?? "Add Product Panel"),
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // ===== Category Grid =====
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final productsByCategory =
                        Provider.of<ProductProvider>(context).productsByCategory;
                    final productCount =
                        productsByCategory[category['name']]?.length ?? 0;

                    final isSelected = selectedCategoryId == category['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryId = category['id'];
                          selectedCategoryName = category['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [primary.withOpacity(0.8), primary]
                                : [secondary.withOpacity(0.8), secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category['name']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$productCount products",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===== Sliding Product Form =====
              if (selectedCategoryId != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Material(
                    elevation: 10,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16)),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add Product to $selectedCategoryName",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    selectedCategoryId = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _productFormKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: nameController,
                                      decoration: inputDecoration("Product Name",
                                          icon: Icons.label),
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                              ? "Enter product name"
                                              : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: priceController,
                                      decoration: inputDecoration("Price",
                                          icon: Icons.money),
                                      keyboardType: TextInputType.number,
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                              ? "Enter price"
                                              : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: imageController,
                                      decoration: inputDecoration("Image URL",
                                          icon: Icons.image),
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                              ? "Enter image URL"
                                              : null,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add Product"),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        backgroundColor: primary,
                                      ),
                                      onPressed: submitProduct,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

    floatingActionButton: FloatingActionButton(
      onPressed: showAddCategorySheet,
      child: const Icon(Icons.add),
      backgroundColor: primary,
      tooltip: "Add Category",
    ),
  );
}
}

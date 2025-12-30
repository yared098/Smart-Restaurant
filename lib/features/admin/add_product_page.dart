import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/product.dart';
import '../../core/providers/product_provider.dart';
import '../../core/services/api_service.dart';

class AddProductPanel extends StatefulWidget {
  const AddProductPanel({super.key});

  @override
  State<AddProductPanel> createState() => _AddProductPanelState();
}

class _AddProductPanelState extends State<AddProductPanel> {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to load categories")));
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

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Product Added!")));

        // Clear form for next product
        nameController.clear();
        priceController.clear();
        imageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to add product")));
      }
    }
  }

  void submitCategory() async {
    if (_categoryFormKey.currentState!.validate()) {
      final newCategory = {"name": categoryNameController.text};

      try {
        await api.addCategory(newCategory);
        categoryNameController.clear();
        Navigator.pop(context); // close bottom sheet
        fetchCategories(); // refresh grid
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Category Added!")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to add category")));
      }
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16),
        child: Form(
          key: _categoryFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoryNameController,
                decoration: inputDecoration("Category Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter category name" : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // ===== Category Grid =====
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: GridView.builder(
              //     itemCount: categories.length,
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 2,
              //       mainAxisSpacing: 12,
              //       crossAxisSpacing: 12,
              //       childAspectRatio: 1.2,
              //     ),
              //     itemBuilder: (context, index) {
              //       final category = categories[index];
              //       return GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             selectedCategoryId = category['id'];
              //             selectedCategoryName = category['name'];
              //           });
              //         },
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(16),
              //             gradient: LinearGradient(
              //               colors: [Colors.orange.shade200, Colors.orange.shade400],
              //               begin: Alignment.topLeft,
              //               end: Alignment.bottomRight,
              //             ),
              //             boxShadow: [
              //               BoxShadow(
              //                 color: Colors.orange.shade100,
              //                 blurRadius: 4,
              //                 offset: const Offset(2, 2),
              //               ),
              //             ],
              //           ),
              //           padding: const EdgeInsets.all(12),
              //           child: Center(
              //             child: Text(category['name']!,
              //                 style: const TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 18)),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
Padding(
  padding: const EdgeInsets.all(16.0),
  child: GridView.builder(
    itemCount: categories.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
    ),
    itemBuilder: (context, index) {
      final category = categories[index];
      final productsByCategory = Provider.of<ProductProvider>(context).productsByCategory;

      final productCount = productsByCategory[category['name']]?.length ?? 0;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedCategoryId = category['id'];
            selectedCategoryName = category['name'];
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade100,
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category['name']!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "$productCount products",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Material(
                    elevation: 8,
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
                                      decoration: inputDecoration("Product Name"),
                                      validator: (val) => val == null || val.isEmpty
                                          ? "Enter product name"
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: priceController,
                                      decoration: inputDecoration("Price"),
                                      keyboardType: TextInputType.number,
                                      validator: (val) => val == null || val.isEmpty
                                          ? "Enter price"
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: imageController,
                                      decoration: inputDecoration("Image URL"),
                                      validator: (val) => val == null || val.isEmpty
                                          ? "Enter image URL"
                                          : null,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add Product"),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
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
          );
  }
}

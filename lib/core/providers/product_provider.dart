import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  // Group products by category name
  Map<String, List<Product>> get productsByCategory {
    final Map<String, List<Product>> map = {};
    for (var p in _products) {
      final category = p.categoryName ?? 'Uncategorized';
      if (!map.containsKey(category)) {
        map[category] = [];
      }
      map[category]!.add(p);
    }
    return map;
  }

  // Set entire product list
  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  // Add single product
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  // Update single product
  void updateProduct(Product product) {
    int index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  // Remove product by id
  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}

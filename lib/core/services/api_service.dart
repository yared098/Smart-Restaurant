import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(baseUrl: "http://localhost:3001/api"));

  /// Get all categories and menu items
  Future<List<dynamic>> getMenu() async {
    final res = await dio.get("/menu/");
    return res.data['categories'];
  }


  /// Get only categories
  Future<List<dynamic>> getCategories() async {
    final res = await dio.get("/menu/categories");
    return res.data;
  }

  /// Add new category
  Future<void> addCategory(Map<String, dynamic> data) async {
    await dio.post("/menu/category/add", data: data);
  }

  /// Add new product
  Future<void> addProduct(Map<String, dynamic> data) async {
    await dio.post("/menu/add", data: data);
  }

  /// Update existing product
  Future<void> updateProduct(Map<String, dynamic> data) async {
    await dio.put("/menu/update", data: data);
  }

  /// Delete product by ID
  Future<void> deleteProduct(String itemId) async {
    await dio.delete("/menu/delete/$itemId");
  }

  /// Create order and return the created order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final res = await dio.post("/order/create", data: data);

    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>; // returns {success: true, order: {...}}
    } else {
      throw Exception("Failed to create order");
    }
  }
}

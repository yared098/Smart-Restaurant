class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final bool available; // ✅ added available field

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.available = true, // default true
  });

  // ✅ Make categoryName a named parameter
  factory Product.fromJson(Map<String, dynamic> json, {String categoryName = "Uncategorized"}) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      categoryId: json['categoryId'] ?? "cat_main",
      categoryName: categoryName,
      available: json['available'] ?? true, // handle availability from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'available': available,
    };
  }
}

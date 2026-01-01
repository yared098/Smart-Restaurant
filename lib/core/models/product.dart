class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final bool available; // ✅ availability
  int quantity; // ✅ added quantity (mutable)

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.available = true, // default true
    this.quantity = 0, // default 0
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
      available: json['available'] ?? true,
      quantity: json['quantity'] ?? 0, // read quantity from JSON if exists
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'available': available,
      'quantity': quantity, // include quantity in JSON
    };
  }
}

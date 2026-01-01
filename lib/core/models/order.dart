class OrderItem {
  final String name;
  final String category;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });

  OrderItem copyWith({
    String? name,
    String? category,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
      };
}
class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final String table;
  final String status;
  final String receiver;
  final DateTime createdAt;
  final DateTime? updatedAt; // ✅ NEW FIELD

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.table,
    required this.status,
    required this.receiver,
    required this.createdAt,
    this.updatedAt, // optional
  });

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? total,
    String? table,
    String? status,
    String? receiver,
    DateTime? createdAt,
    DateTime? updatedAt, // ✅ copyWith support
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      table: table ?? this.table,
      status: status ?? this.status,
      receiver: receiver ?? this.receiver,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt, // ✅
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i))
          .toList(),
      total: (json['total'] as num).toDouble(),
      table: json['table'] ?? "Kitchen",
      status: json['status'] ?? "NEW",
      receiver: json['receiver'] ?? "Guest",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null, // ✅ parse optional updatedAt
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'table': table,
        'status': status,
        'receiver': receiver,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(), // ✅ optional
      };
}

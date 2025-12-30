class Order {
  String id;
  List<String> items;
  double total;
  String table;
  String status;
  DateTime createdAt;

  Order({required this.id, required this.items, required this.total, required this.table, this.status = 'NEW', required this.createdAt});

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    items: List<String>.from(json['items']),
    total: json['total'].toDouble(),
    table: json['table'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items,
    'total': total,
    'table': table,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
   /// ✅ Add copyWith method
  Order copyWith({
    String? id,
    List<String>? items,
    double? total,
    String? table,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      table: table ?? this.table,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

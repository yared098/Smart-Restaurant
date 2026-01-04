class RestaurantTable {
  final String id;
  final int tableNumber;
  final String restaurantId;
  final String? assignedWaiterId;
  final bool isActive;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.restaurantId,
    this.assignedWaiterId,
    required this.isActive,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'],
      tableNumber: json['tableNumber'],
      restaurantId: json['restaurantId'],
      assignedWaiterId: json['assignedWaiterId'],
      isActive: json['isActive'] ?? true,
    );
  }
}

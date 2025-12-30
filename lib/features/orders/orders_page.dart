import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/models/order.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to both live orders and history if needed
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text("Order history")),
      body: orders.isEmpty
          ? const Center(child: Text("No incoming orders"))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final o = orders[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    title: Text("Table: ${o.table}"),
                    subtitle: Text(
                        "Items: ${o.items.join(", ")}\nStatus: ${o.status}\nTotal: ${o.total} ETB"),
                    trailing: DropdownButton<String>(
                      value: o.status,
                      items: ['NEW', 'COOKING', 'DONE']
                          .map((status) =>
                              DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          orderProvider.updateOrder(
                              o.copyWith(status: val)); // Update status
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

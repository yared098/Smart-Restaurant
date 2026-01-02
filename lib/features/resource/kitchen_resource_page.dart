import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/providers/resource_provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';

class KitchenResourcesPage extends StatefulWidget {
  @override
  _KitchenResourcesPageState createState() => _KitchenResourcesPageState();
}

class _KitchenResourcesPageState extends State<KitchenResourcesPage> {
  Map<String, int> requestCart = {}; // resourceId -> quantity
  Map<String, Map<String, dynamic>> selectedResources = {}; // id -> resource

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ResourceProvider>(context, listen: false);
    provider.fetchResources();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);
    final config = Provider.of<ConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Resources"),
        backgroundColor: config.primaryColor ?? Colors.blue,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.resources.isEmpty
              ? const Center(child: Text("No resources available"))
              : ListView.builder(
                  itemCount: provider.resources.length,
                  itemBuilder: (_, index) {
                    final res = provider.resources[index];
                    final resId = res['id'] ?? '';
                    final unit = res['unit'] ?? '';

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: res['imageUrl'] != null &&
                                res['imageUrl'].isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  res['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.inventory),
                              ),
                        title: Text(res['name'] ?? ''),
                        subtitle: Text(
                            "Available: ${res['quantity'] ?? 0} ${unit.toString()}"),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: requestCart[resId] != null &&
                                        requestCart[resId]! > 0
                                    ? () {
                                        setState(() {
                                          requestCart[resId] =
                                              requestCart[resId]! - 1;
                                          if (requestCart[resId] == 0) {
                                            requestCart.remove(resId);
                                            selectedResources.remove(resId);
                                          }
                                        });
                                      }
                                    : null,
                              ),
                              Text(requestCart[resId]?.toString() ?? '0'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    final qty = requestCart[resId] ?? 0;
                                    if (qty < (res['quantity'] ?? 1000)) {
                                      requestCart[resId] = qty + 1;
                                      selectedResources[resId] = res;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: requestCart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${requestCart.length} item(s) in cart",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: config.primaryColor),
                    onPressed: () async {
                      // Prepare items for request
                      final items = selectedResources.entries
                          .map((e) => {
                                "resourceId": e.key,
                                "quantity": requestCart[e.key],
                              })
                          .toList();

                      // Send request via provider
                      await provider.createRequest(items, note: "Kitchen request");
                      setState(() {
                        requestCart.clear();
                        selectedResources.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Request sent")),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Send Request"),
                  ),
                ],
              ),
            ),
    );
  }
}

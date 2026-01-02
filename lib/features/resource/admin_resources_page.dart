import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/providers/resource_provider.dart';

class AdminResourcesPage extends StatefulWidget {
  @override
  _AdminResourcesPageState createState() => _AdminResourcesPageState();
}

class _AdminResourcesPageState extends State<AdminResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch resources and requests on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ResourceProvider>(context, listen: false);
      provider.fetchResources();
      provider.fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Resources"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Resources"),
            Tab(text: "Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ================= Resources Tab =================
          provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.resources.isEmpty
                  ? const Center(child: Text("No resources available"))
                  : ListView.builder(
                      itemCount: provider.resources.length,
                      itemBuilder: (_, index) {
                        final res = provider.resources[index];
                        final resId = res['id']?.toString() ?? '';
                        return ListTile(
                          title: Text(res['name'] ?? ''),
                          subtitle: Text("${res['quantity'] ?? 0} ${res['unit'] ?? ''}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showResourcePanel(context, provider, resource: res),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: resId.isNotEmpty
                                    ? () async {
                                        await provider.deleteResource(resId);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Resource deleted")));
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

          // ================= Requests Tab =================
          provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.requests.isEmpty
                  ? const Center(child: Text("No resource requests"))
                  : ListView.builder(
                      itemCount: provider.requests.length,
                      itemBuilder: (_, index) {
                        final req = provider.requests[index];
                        final reqId = req['id']?.toString() ?? '';
                        final items = (req['items'] as List<dynamic>?) ?? [];

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text("Request #${reqId.isNotEmpty ? reqId.substring(0, 8) : ''}"),
                            subtitle: Text("Status: ${req['status'] ?? ''}"),
                            children: [
                              ...items.map<Widget>((item) => ListTile(
                                    title: Text(item['name'] ?? ''),
                                    trailing: Text("${item['quantity'] ?? 0} ${item['unit'] ?? ''}"),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (req['status'] == "PENDING" && reqId.isNotEmpty) ...[
                                      ElevatedButton(
                                        onPressed: () async {
                                          await provider.approveRequest(reqId);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Request approved")));
                                        },
                                        child: const Text("Approve"),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => _showRejectDialog(context, provider, reqId),
                                        child: const Text("Reject"),
                                      ),
                                    ] else
                                      Text("Processed at: ${req['approvedAt'] ?? ''}"),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _showResourcePanel(context, provider),
            )
          : null,
    );
  }

  // ================= Resource Add/Edit Panel =================
  void _showResourcePanel(BuildContext context, ResourceProvider provider,
      {Map<String, dynamic>? resource}) {
    final nameController = TextEditingController(text: resource?['name'] ?? '');
    final quantityController =
        TextEditingController(text: resource?['quantity']?.toString() ?? '');
    final unitController = TextEditingController(text: resource?['unit'] ?? '');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Resource Panel",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.white,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource == null ? "Add Resource" : "Edit Resource",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: unitController, decoration: const InputDecoration(labelText: "Unit")),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final data = {
                            "name": nameController.text,
                            "quantity": int.tryParse(quantityController.text) ?? 0,
                            "unit": unitController.text,
                          };

                          Navigator.pop(context);

                          try {
                            if (resource == null) {
                              await provider.addResource(data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Resource added")));
                            } else {
                              final resId = resource['id']?.toString() ?? '';
                              if (resId.isNotEmpty) {
                                await provider.updateResource(resId, data);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Resource updated")));
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text("Failed to save resource")));
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(anim1),
        child: child,
      ),
    );
  }

  // ================= Reject Request Dialog =================
  void _showRejectDialog(BuildContext context, ResourceProvider provider, String requestId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Request"),
        content: TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await provider.rejectRequest(requestId, reason: reasonController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Request rejected")));
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }
}

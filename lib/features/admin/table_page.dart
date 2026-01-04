import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/table_provider.dart';
import '../../core/providers/human_resource_provider.dart';
import '../../core/providers/config_provider.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tableProvider = context.read<TableProvider>();
      tableProvider.fetchTables();
    });
  }

  // Determine number of columns based on screen width
  int _calculateGridColumns(double width) {
    if (width >= 1200) return 8; // large
    if (width >= 800) return 4;  // medium
    if (width >= 500) return 2;  // small
    return 1;                     // extra small
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = context.watch<TableProvider>();
    final hrProvider = context.watch<HumanResourceProvider>();
    final configProvider = context.watch<ConfigProvider>();

    final primary = configProvider.primaryColor ?? Colors.deepOrange;
    final secondary = configProvider.secondaryColor ?? Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(configProvider.appName ?? "Restaurant Tables"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: const Icon(Icons.add),
        onPressed: () => _showCreateDialog(context, primary),
      ),
      body: tableProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : tableProvider.tables.isEmpty
              ? const Center(
                  child: Text(
                    "No tables available",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        _calculateGridColumns(constraints.maxWidth);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: tableProvider.tables.length,
                        itemBuilder: (_, index) {
                          final table = tableProvider.tables[index];

                          final waiter = hrProvider.hrList.firstWhere(
                            (hr) =>
                                hr['id'] == table.assignedWaiterId &&
                                hr['role'].toLowerCase() == "waiter",
                            orElse: () => null,
                          );
                          final waiterName = waiter != null
                              ? (waiter['fullname'] ??
                                  waiter['name'] ??
                                  "Unknown")
                              : null;

                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: secondary.withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: primary,
                                        child: Text(
                                          table.tableNumber.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Table ${table.tableNumber}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    waiterName != null
                                        ? "Assigned to: $waiterName"
                                        : "No waiter assigned",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: waiterName != null
                                          ? Colors.green[700]
                                          : Colors.red,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (waiterName != null)
                                        IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: Colors.red),
                                          onPressed: () async {
                                            try {
                                              await tableProvider
                                                  .unassignWaiter(table.id);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "Waiter unassigned")),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Failed: $e")),
                                              );
                                            }
                                          },
                                        ),
                                      IconButton(
                                        icon: Icon(Icons.person_add,
                                            color: primary),
                                        onPressed: () {
                                          _showAssignDialog(
                                              context, table.id, primary);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showCreateDialog(BuildContext context, Color primary) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Tables"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter number of new tables (e.g. 10)",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: const Text("Add"),
            onPressed: () async {
              final total = int.tryParse(controller.text);
              if (total == null || total <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid number")),
                );
                return;
              }

              final provider = context.read<TableProvider>();
              provider.refreshToken();

              try {
                await provider.createTables(total);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tables added successfully")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add tables: $e")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(
      BuildContext context, String tableId, Color primary) {
    final hrProvider = context.read<HumanResourceProvider>();
    final tableProvider = context.read<TableProvider>();
    String? selectedWaiterId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Assign Waiter"),
        content: FutureBuilder(
          future: hrProvider.fetchHR(),
          builder: (context, snapshot) {
            if (hrProvider.loading) return const Center(child: CircularProgressIndicator());
            if (hrProvider.hrList.isEmpty) return const Text("No waiters available");

            return DropdownButton<String>(
              isExpanded: true,
              value: selectedWaiterId,
              hint: const Text("Select a waiter"),
              items: hrProvider.hrList
                  .where((hr) => hr['role'].toLowerCase() == "waiter")
                  .map<DropdownMenuItem<String>>(
                    (hr) => DropdownMenuItem(
                      value: hr['id'],
                      child: Text(hr['fullname'] ?? hr['name'] ?? "Unknown"),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWaiterId = value;
                });
              },
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: const Text("Assign"),
            onPressed: () async {
              if (selectedWaiterId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Select a waiter")),
                );
                return;
              }

              try {
                await tableProvider.assignWaiter(tableId, selectedWaiterId!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Waiter assigned successfully")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to assign waiter: $e")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

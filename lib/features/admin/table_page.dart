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
  bool _isSlideOpen = false;
  bool _isAssignMode = false;
  String? _assignTableId;

  final TextEditingController _tableController = TextEditingController();
  String? _selectedWaiterId;

  bool _hrLoading = false;
  List<Map<String, dynamic>> _waiters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableProvider>().fetchTables();
    });
  }

  int _calculateGridColumns(double width) {
    if (width >= 1200) return 8;
    if (width >= 800) return 4;
    if (width >= 500) return 2;
    return 1;
  }

  void _openAddTables() {
    setState(() {
      _isSlideOpen = true;
      _isAssignMode = false;
      _tableController.clear();
    });
  }

  Future<void> _openAssignWaiter(String tableId) async {
    setState(() {
      _isSlideOpen = true;
      _isAssignMode = true;
      _assignTableId = tableId;
      _selectedWaiterId = null;
      _hrLoading = true;
    });

    try {
      await context.read<HumanResourceProvider>().fetchHR();
      final hrList = context
          .read<HumanResourceProvider>()
          .hrList
          .where((hr) => hr['role'].toLowerCase() == "waiter")
          .toList();
      setState(() {
        _waiters = List<Map<String, dynamic>>.from(hrList);
        _hrLoading = false;
      });
    } catch (_) {
      setState(() {
        _waiters = [];
        _hrLoading = false;
      });
    }
  }

  void _closeSlide() {
    setState(() {
      _isSlideOpen = false;
    });
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
        onPressed: _openAddTables,
      ),
      body: Stack(
        children: [
          // Main Grid
          tableProvider.loading
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (waiterName != null)
                                            IconButton(
                                              icon: const Icon(Icons.clear,
                                                  color: Colors.red),
                                              onPressed: () async {
                                                try {
                                                  await tableProvider
                                                      .unassignWaiter(
                                                          table.id);
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
                                              _openAssignWaiter(table.id);
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

          // Right Side Slide Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            right: _isSlideOpen ? 0 : -MediaQuery.of(context).size.width * 0.5,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Material(
              elevation: 20,
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _isAssignMode
                      ? _buildAssignForm(tableProvider, primary)
                      : _buildAddTablesForm(tableProvider, primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTablesForm(TableProvider tableProvider, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Add Tables",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeSlide,
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _tableController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Number of tables",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: const Text("Add"),
            onPressed: () async {
              final total = int.tryParse(_tableController.text);
              if (total == null || total <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid number")),
                );
                return;
              }

              tableProvider.refreshToken();
              try {
                await tableProvider.createTables(total);
                _closeSlide();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tables added successfully")),
                );
              } catch (e) {
                _closeSlide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add tables: $e")),
                );
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildAssignForm(TableProvider tableProvider, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Assign Waiter",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeSlide,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _hrLoading
            ? const Center(child: CircularProgressIndicator())
            : _waiters.isEmpty
                ? const Text("No waiters available")
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedWaiterId,
                    decoration: InputDecoration(
                      labelText: "Select Waiter",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _waiters
                        .map((hr) => DropdownMenuItem<String>(
                              value: hr['id'],
                              child:
                                  Text(hr['fullname'] ?? hr['name'] ?? "Unknown"),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWaiterId = value;
                      });
                    },
                  ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: const Text("Assign"),
            onPressed: () async {
              if (_selectedWaiterId == null || _assignTableId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Select a waiter")),
                );
                return;
              }

              try {
                await tableProvider.assignWaiter(_assignTableId!, _selectedWaiterId!);
                _closeSlide();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Waiter assigned successfully")),
                );
              } catch (e) {
                _closeSlide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to assign waiter: $e")),
                );
              }
            },
          ),
        )
      ],
    );
  }
}

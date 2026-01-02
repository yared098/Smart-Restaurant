import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/providers/human_resource_provider.dart';

enum Role { Kitchen, Waiter, Manager, Cashier }

extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.Kitchen:
        return "Kitchen Staff";
      case Role.Waiter:
        return "Waiter";
      case Role.Manager:
        return "Manager";
      case Role.Cashier:
        return "Cashier";
      default:
        return "";
    }
  }
}

class AdminHumanResourcesPage extends StatefulWidget {
  @override
  _AdminHumanResourcesPageState createState() => _AdminHumanResourcesPageState();
}

class _AdminHumanResourcesPageState extends State<AdminHumanResourcesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HumanResourceProvider>(context, listen: false).fetchHR();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Human Resources")),
      body: Consumer<HumanResourceProvider>(
        builder: (context, provider, _) {
          if (provider.loading) return Center(child: CircularProgressIndicator());
          if (provider.hrList.isEmpty) return Center(child: Text("No staff found"));

          return ListView.builder(
            itemCount: provider.hrList.length,
            itemBuilder: (_, index) {
              final hr = provider.hrList[index];
              return ListTile(
                title: Text(hr['username'] ?? ''),
                subtitle: Text("Role: ${hr['role'] ?? ''}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showSidePanel(context, provider, hr: hr),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => provider.deleteHR(hr['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showSidePanel(context, Provider.of<HumanResourceProvider>(context, listen: false)),
      ),
    );
  }

  void _showSidePanel(BuildContext pageContext, HumanResourceProvider provider, {Map<String, dynamic>? hr}) {
    final usernameController = TextEditingController(text: hr?['username'] ?? '');
    final passwordController = TextEditingController();
    Role? selectedRole = hr != null && hr['role'] != null
        ? Role.values.firstWhere((r) => r.name == hr['role'], orElse: () => Role.Kitchen)
        : null;

    showGeneralDialog(
      context: pageContext,
      barrierDismissible: true,
      barrierLabel: "HR Panel",
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.white,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.all(16),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Text(hr == null ? "Add HR" : "Edit HR",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username")),
                        SizedBox(height: 10),
                        if (hr == null)
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: "Password"),
                            obscureText: true,
                          ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<Role>(
                          value: selectedRole,
                          decoration: InputDecoration(labelText: "Role"),
                          items: Role.values
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role.name),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedRole = val;
                            });
                          },
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () => Navigator.pop(pageContext),
                                child: Text("Cancel")),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                // ✅ Validate fields
                                if (usernameController.text.isEmpty ||
                                    (hr == null && passwordController.text.isEmpty) ||
                                    selectedRole == null) {
                                  ScaffoldMessenger.of(pageContext).showSnackBar(
                                    SnackBar(content: Text("Please fill all fields")),
                                  );
                                  return;
                                }

                                final data = {
                                  "username": usernameController.text,
                                  "password": passwordController.text,
                                  "role": selectedRole!.name,
                                };

                                Navigator.pop(pageContext); // Close dialog

                                try {
                                  if (hr == null) {
                                    await provider.addHR(data);
                                    ScaffoldMessenger.of(pageContext).showSnackBar(
                                      SnackBar(content: Text("HR added")),
                                    );
                                  } else {
                                    final hrId = hr['id'] ?? '';
                                    await provider.updateHR(hrId, data);
                                    ScaffoldMessenger.of(pageContext).showSnackBar(
                                      SnackBar(content: Text("HR updated")),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(pageContext).showSnackBar(
                                    SnackBar(content: Text("Failed to save HR")),
                                  );
                                }
                              },
                              child: Text("Save"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

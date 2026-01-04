import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/providers/human_resource_provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';

enum Role { Kitchen, Waiter, Manager, Cashier }

extension RoleExtension on Role {
  /// Value sent to / received from backend
  String get value => name; // Kitchen, Waiter, Manager, Cashier

  /// Label shown in UI
  String get label {
    switch (this) {
      case Role.Kitchen:
        return "Kitchen Staff";
      case Role.Waiter:
        return "Waiter";
      case Role.Manager:
        return "Manager";
      case Role.Cashier:
        return "Cashier";
    }
  }

  /// Convert backend string → enum
  static Role fromBackend(String value) {
    return Role.values.firstWhere(
      (r) => r.name == value,
      orElse: () => Role.Kitchen,
    );
  }
}


class AdminHumanResourcesPage extends StatefulWidget {
  @override
  _AdminHumanResourcesPageState createState() =>
      _AdminHumanResourcesPageState();
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
    final config = Provider.of<ConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Human Resources"),
        backgroundColor: config.primaryColor ?? Colors.teal,
      ),
      body: Consumer<HumanResourceProvider>(
        builder: (context, provider, _) {
          if (provider.loading)
            return Center(child: CircularProgressIndicator());
          if (provider.hrList.isEmpty)
            return Center(child: Text("No staff found"));

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: provider.hrList.length,
            itemBuilder: (_, index) {
              final hr = provider.hrList[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(hr['name'] ?? '',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Username: ${hr['username'] ?? ''}"),
                      Text("Role: ${hr['role'] ?? ''}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: config.primaryColor),
                        onPressed: () =>
                            _showSidePanel(context, provider, config, hr: hr),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.deleteHR(hr['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<ConfigProvider>(
        builder: (context, config, _) => FloatingActionButton(
          backgroundColor: config.primaryColor ?? Colors.teal,
          child: Icon(Icons.add),
          onPressed: () =>
              _showSidePanel(context, Provider.of<HumanResourceProvider>(context, listen: false), config),
        ),
      ),
    );
  }

  void _showSidePanel(BuildContext pageContext, HumanResourceProvider provider,
      ConfigProvider config,
      {Map<String, dynamic>? hr}) {
    final nameController = TextEditingController(text: hr?['name'] ?? '');
    final usernameController =
        TextEditingController(text: hr?['username'] ?? '');
    final passwordController = TextEditingController();
    bool showPassword = false;
    Role? selectedRole = hr != null && hr['role'] != null
        ? Role.values.firstWhere((r) => r.name == hr['role'],
            orElse: () => Role.Kitchen)
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
                  padding: EdgeInsets.all(24),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hr == null ? "Add HR" : "Edit HR",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: config.primaryColor ?? Colors.teal),
                        ),
                        SizedBox(height: 24),
                        _buildTextField(
                            controller: nameController,
                            label: "Name",
                            color: config.primaryColor),
                        SizedBox(height: 16),
                        _buildTextField(
                            controller: usernameController,
                            label: "Username",
                            color: config.primaryColor),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: passwordController,
                          label: hr == null
                              ? "Password"
                              : "Password (leave blank to keep)",
                          obscureText: !showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          color: config.primaryColor,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<Role>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: "Role",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
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
                                child: Text("Cancel",
                                    style: TextStyle(color: Colors.grey))),
                            SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    config.primaryColor ?? Colors.teal,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                if (nameController.text.isEmpty ||
                                    usernameController.text.isEmpty ||
                                    selectedRole == null ||
                                    (hr == null &&
                                        passwordController.text.isEmpty)) {
                                  ScaffoldMessenger.of(pageContext).showSnackBar(
                                    SnackBar(
                                        content: Text("Please fill all fields")),
                                  );
                                  return;
                                }

                                final data = {
                                  "name": nameController.text,
                                  "username": usernameController.text,
                                  "role": selectedRole!.name,
                                };

                                if (passwordController.text.isNotEmpty) {
                                  data['password'] = passwordController.text;
                                }

                                Navigator.pop(pageContext);

                                try {
                                  if (hr == null) {
                                    await provider.addHR(data);
                                    ScaffoldMessenger.of(pageContext).showSnackBar(
                                        SnackBar(content: Text("HR added")));
                                  } else {
                                    final hrId = hr['id'] ?? '';
                                    await provider.updateHR(hrId, data);
                                    ScaffoldMessenger.of(pageContext).showSnackBar(
                                        SnackBar(content: Text("HR updated")));
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(pageContext).showSnackBar(
                                      SnackBar(content: Text("Failed to save HR")));
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool obscureText = false,
      Widget? suffixIcon,
      Color? color}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color ?? Colors.teal)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color ?? Colors.teal, width: 2)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

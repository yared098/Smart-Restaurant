import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../core/providers/config_provider.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _formKey = GlobalKey<FormState>();

  final _appNameController = TextEditingController();
  final _appLogoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _welcomeMessageController = TextEditingController();

  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.orange;
  bool _enableOrders = true;

  bool _showLogoEditor = false;
  bool _showCredentials = false; // Hide username/password by default
  bool _passwordVisible = false;  // Password toggle
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final config = context.read<ConfigProvider>();

    _appNameController.text = config.appName ?? '';
    _appLogoController.text = config.appLogo;
    _welcomeMessageController.text = config.welcomeMessage ?? '';
    _primaryColor = config.primaryColor ?? _primaryColor;
    _secondaryColor = config.secondaryColor ?? _secondaryColor;
    _enableOrders = config.enableOrders;
    _usernameController.text = config.username;
    _passwordController.text = config.password;

    _initialized = true;
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _appLogoController.dispose();
    _welcomeMessageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _pickColor(Color current, ValueChanged<Color> onSelect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick Color"),
        content: ColorPicker(
          pickerColor: current,
          onColorChanged: onSelect,
          enableAlpha: false,
          displayThumbColor: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<ConfigProvider>().updateConfig({
      "appName": _appNameController.text,
      "appLogo": _appLogoController.text,
      "welcomeMessage": _welcomeMessageController.text,
      "primaryColor": _colorToHex(_primaryColor),
      "secondaryColor": _colorToHex(_secondaryColor),
      "enableOrders": _enableOrders,
      "username": _usernameController.text,
      "password": _passwordController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configuration Updated")),
    );

    setState(() => _showLogoEditor = false);
  }

  Widget _colorTile(String title, Color color, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(_colorToHex(color)),
      trailing: CircleAvatar(backgroundColor: color),
      onTap: onTap,
    );
  }

  Widget _credentialsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Username & Password"),
              trailing: Icon(
                  _showCredentials ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onTap: () => setState(() => _showCredentials = !_showCredentials),
            ),
            if (_showCredentials) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Configuration"),
        backgroundColor: _primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _appNameController,
                        decoration: const InputDecoration(
                          labelText: "App Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      if (_appLogoController.text.isNotEmpty)
                        Column(
                          children: [
                            Image.network(
                              _appLogoController.text,
                              height: 80,
                              errorBuilder: (_, __, ___) =>
                                  const Text("Invalid Image URL"),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text("Change Logo"),
                              onPressed: () =>
                                  setState(() => _showLogoEditor = true),
                            ),
                          ],
                        ),
                      if (_showLogoEditor)
                        TextFormField(
                          controller: _appLogoController,
                          decoration: const InputDecoration(
                            labelText: "App Logo URL",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _welcomeMessageController,
                        decoration: const InputDecoration(
                          labelText: "Welcome Message",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _colorTile(
                        "Primary Color",
                        _primaryColor,
                        () => _pickColor(
                          _primaryColor,
                          (c) => setState(() => _primaryColor = c),
                        ),
                      ),
                      _colorTile(
                        "Secondary Color",
                        _secondaryColor,
                        () => _pickColor(
                          _secondaryColor,
                          (c) => setState(() => _secondaryColor = c),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text("Enable Orders"),
                        value: _enableOrders,
                        onChanged: (v) => setState(() => _enableOrders = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _credentialsSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Configuration"),
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

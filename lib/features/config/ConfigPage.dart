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
  bool _showCredentials = false;
  bool _passwordVisible = false;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Pick Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: onSelect,
            enableAlpha: false,
            displayThumbColor: true,
          ),
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

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_colorToHex(color)),
        trailing: CircleAvatar(
          backgroundColor: color,
          radius: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _credentialsSection(Color primary) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.lock, color: primary),
              title: const Text("Change Username & Password"),
              trailing: Icon(
                  _showCredentials ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onTap: () => setState(() => _showCredentials = !_showCredentials),
            ),
            if (_showCredentials) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    final primary = _primaryColor;
    final secondary = _secondaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Configuration"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== General Settings Card =====
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                shadowColor: primary.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _appNameController,
                        decoration: InputDecoration(
                          labelText: "App Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      if (_appLogoController.text.isNotEmpty)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _appLogoController.text,
                                height: 80,
                                errorBuilder: (_, __, ___) =>
                                    const Text("Invalid Image URL"),
                              ),
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
                          decoration: InputDecoration(
                            labelText: "App Logo URL",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _welcomeMessageController,
                        decoration: InputDecoration(
                          labelText: "Welcome Message",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _colorTile("Primary Color", primary, () {
                        _pickColor(primary, (c) => setState(() => _primaryColor = c));
                      }),
                      _colorTile("Secondary Color", secondary, () {
                        _pickColor(secondary, (c) => setState(() => _secondaryColor = c));
                      }),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text("Enable Orders"),
                        value: _enableOrders,
                        activeColor: primary,
                        onChanged: (v) => setState(() => _enableOrders = v),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Credentials Card =====
              _credentialsSection(primary),

              // ===== Save Button =====
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Configuration"),
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
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

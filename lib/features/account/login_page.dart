import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_restaurant/core/providers/auth_provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  // ------------------ Clear Old Credentials ------------------
  void _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');

    // Also clear the provider state if needed
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    // Clear text fields
    _usernameController.clear();
    _passwordController.clear();

    setState(() {
      _error = "Old credentials cleared!";
    });

    print("✅ Old credentials cleared from SharedPreferences");
  }

void _login() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  try {
    await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    // Debug: print login info
    print("Login role raw: '${authProvider.role}'");

    // Normalize role: trim spaces, lowercase
    String role = authProvider.role?.trim().toLowerCase() ?? "";
    print("Normalized role: '$role'");

    // Navigate based on role
    switch (role) {
      case "admin":
        context.go('/admin');
        break;
      case "kitchen":
        context.go('/kitchen');
        break;
      case "waiter":
        context.go('/host');
        break;
      default:
        context.go('/scan');
    }
  } catch (e) {
    print(e);
    setState(() {
      _error = e.toString().replaceAll("Exception: ", "");
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);

    final primaryColor = config.primaryColor ?? Colors.blue;
    final secondaryColor = config.secondaryColor ?? Colors.green;

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.1),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / App Name
                  if (config.appLogo.isNotEmpty)
                    Image.network(config.appLogo, height: 80)
                  else
                    Text(
                      config.appName ?? "Smart Restaurant",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    config.welcomeMessage ??
                        "Welcome! Please login to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Username
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Error message
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: secondaryColor,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _loading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("Login NEW"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Clear Credentials Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearCredentials,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: secondaryColor, width: 2),
                      ),
                      child: Text(
                        "Clear Old Credentials",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  // Default credentials hint
                  Text(
                    "Default: admin / 123456",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

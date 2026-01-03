import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../features/account/login_page.dart';
import 'package:go_router/go_router.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  final List<String>? allowedRoles;

  const AuthWrapper({super.key, required this.child, this.allowedRoles});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Not logged in → redirect to login
    if (!auth.isLoggedIn) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox.shrink();
    }

    // Role not allowed → redirect to login
    if (allowedRoles != null) {
      final userRole = auth.role?.trim().toLowerCase() ?? "";
      final normalizedAllowedRoles =
          allowedRoles!.map((r) => r.trim().toLowerCase()).toList();

      if (!normalizedAllowedRoles.contains(userRole)) {
        Future.microtask(() => context.go('/login'));
        return const SizedBox.shrink();
      }
    }

    // Allowed → show the child
    return child;
  }
}

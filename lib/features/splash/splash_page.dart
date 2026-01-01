import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/config_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // 🔑 Wait until first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final configProvider =
        Provider.of<ConfigProvider>(context, listen: false);

    try {
      // Optional: small delay so user sees splash
      await Future.delayed(const Duration(milliseconds: 500));

      await configProvider.loadConfig();

      if (!mounted) return;

      if (configProvider.appName != null &&
          configProvider.appName!.isNotEmpty) {
        context.go('/scan');
      } else {
        context.go('/config');
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/config');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔹 Use logo if available
            Consumer<ConfigProvider>(
              builder: (_, config, __) {
                if (config.appLogo.isNotEmpty) {
                  return Image.network(
                    config.appLogo,
                    height: 120,
                  );
                }
                return const Icon(
                  Icons.restaurant,
                  size: 100,
                );
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text("Loading restaurant configuration..."),
          ],
        ),
      ),
    );
  }
}

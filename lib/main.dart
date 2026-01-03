import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/core/providers/auth_provider.dart';
import 'package:smart_restaurant/core/providers/config_provider.dart';
import 'package:smart_restaurant/core/providers/human_resource_provider.dart';
import 'package:smart_restaurant/core/providers/kitchen_provider.dart';
import 'package:smart_restaurant/core/providers/resource_provider.dart';
import 'package:smart_restaurant/core/services/config_service.dart';
import 'package:smart_restaurant/core/services/kitchen_service.dart';
import 'package:smart_restaurant/core/services/notification_service.dart';
import 'package:smart_restaurant/core/services/resource_service.dart';
import 'app/router.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/services/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // Initialize notifications

  final configService = ConfigService();
  final kitchenService = KitchenService(); // lowercase
   final resourceProvider = ResourceService(); // lowercase

  final configProvider = ConfigProvider(configService: configService);

  await configProvider.loadConfig(); // ✅ load once

  final socketService = SocketService();
  socketService.connect();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: configProvider, // ✅ USE SAME INSTANCE
        ),
        
        ChangeNotifierProvider(create: (_) => HumanResourceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider(kitchenService: kitchenService)),
        ChangeNotifierProvider(
          create: (_) {
            final provider = OrderProvider(socketService: socketService);
            provider.init("");
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

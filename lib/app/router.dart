import 'package:go_router/go_router.dart';
import 'package:smart_restaurant/features/resource/kitchen_resource_page.dart';
import 'package:smart_restaurant/features/splash/splash_page.dart';
import 'package:smart_restaurant/features/config/ConfigPage.dart';
import 'package:smart_restaurant/features/qr/qr_scanner_page.dart';
import 'package:smart_restaurant/features/menu/menu_page.dart';
import 'package:smart_restaurant/features/Kitchen/kitchen_dashboard.dart';
import 'package:smart_restaurant/features/orders/waiter_dashboard.dart';
import 'package:smart_restaurant/features/admin/admin_dashboard.dart';
import 'package:smart_restaurant/features/admin/add_product_page.dart';
import 'package:smart_restaurant/features/orders/orders_page.dart';

final router = GoRouter(
  initialLocation: '/', // ✅ Splash first
  routes: [
    /// 🔹 Splash
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),

    /// 🔹 Config / Setup
    GoRoute(path: '/config', builder: (_, __) => const ConfigPage()),

    /// 🔹 Admin
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),

    /// 🔹 Kitchen
    GoRoute(path: '/kitchen', builder: (_, __) => const KitchenDashboard()),

    /// 🔹 Kitchen
    GoRoute(path: '/host', builder: (_, __) => const waiter_dashboard()),

    /// 🔹 Menu
    GoRoute(
      path: '/menu/:restaurantId',
      builder: (context, state) {
        final restaurantId = state.pathParameters['restaurantId']!;
        return MenuPage(restaurantId: restaurantId);
      },
    ),

    GoRoute(path: '/resource', builder: (_, __) => KitchenResourcesPage()),

    GoRoute(path: '/admin/add', builder: (_, __) => const AddProductPanel()),

    /// 🔹 Orders
    GoRoute(path: '/orders', builder: (_, __) => const OrdersPage()),

    /// 🔹 QR Scan
    GoRoute(
      path: '/scan',
      builder: (_, __) => const QRGeneratorPage(restaurantId: "rest_001"),
    ),
  ],
);

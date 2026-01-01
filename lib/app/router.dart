// import 'package:go_router/go_router.dart';
// import 'package:smart_restaurant/features/Kitchen/HostessPage.dart';
// import 'package:smart_restaurant/features/config/ConfigPage.dart';
// import 'package:smart_restaurant/features/orders/waiter_dashboard.dart';
// import '../features/qr/qr_scanner_page.dart';
// import '../features/menu/menu_page.dart';
// import '../features/admin/admin_dashboard.dart';
// import '../features/admin/add_product_page.dart';
// import '../features/orders/orders_page.dart';

// final router = GoRouter(
//   initialLocation: "/scan",
//   routes: [
//     GoRoute(path: "/scan", builder: (_, __) => const QRGeneratorPage(restaurantId: "rest_001",)),
//     GoRoute(path: "/config", builder: (_, __) => const ConfigPage()),
//     GoRoute(path: "/host", builder: (_, __) => const HostessPage()),

//     GoRoute(
//       path: '/menu/:restaurantId',
//       builder: (context, state) {
//         final restaurantId = state.pathParameters['restaurantId']!;
//         return MenuPage(restaurantId: restaurantId);
//       },
//     ),
//     GoRoute(
//       path: "/menu/:id",
//       builder: (ctx, state) {
//         final restaurantId = state.pathParameters['id']!;
//         return MenuPage(restaurantId: restaurantId); // Pass restaurantId
//       },
//     ),
//         GoRoute(path: "/kitchen", builder: (_, __) => const KitchenDashboardPage()),

//     GoRoute(path: "/admin", builder: (_, __) => const AdminDashboard()),
//     GoRoute(path: "/admin/add", builder: (_, __) => const AddProductPanel()),
//     GoRoute(path: "/orders", builder: (_, __) => const OrdersPage()),
//   ],
// );

import 'package:go_router/go_router.dart';
import 'package:smart_restaurant/features/splash/splash_page.dart';
import 'package:smart_restaurant/features/config/ConfigPage.dart';
import 'package:smart_restaurant/features/qr/qr_scanner_page.dart';
import 'package:smart_restaurant/features/menu/menu_page.dart';
import 'package:smart_restaurant/features/Kitchen/HostessPage.dart';
import 'package:smart_restaurant/features/orders/waiter_dashboard.dart';
import 'package:smart_restaurant/features/admin/admin_dashboard.dart';
import 'package:smart_restaurant/features/admin/add_product_page.dart';
import 'package:smart_restaurant/features/orders/orders_page.dart';

final router = GoRouter(
  initialLocation: '/', // ✅ Splash first
  routes: [
    /// 🔹 Splash
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashPage(),
    ),

    /// 🔹 Config / Setup
    GoRoute(
      path: '/config',
      builder: (_, __) => const ConfigPage(),
    ),

    /// 🔹 QR Scan
    GoRoute(
      path: '/scan',
      builder: (_, __) => const QRGeneratorPage(
        restaurantId: "rest_001",
      ),
    ),

    /// 🔹 Hostess
    GoRoute(
      path: '/host',
      builder: (_, __) => const HostessPage(),
    ),

    /// 🔹 Menu
    GoRoute(
      path: '/menu/:restaurantId',
      builder: (context, state) {
        final restaurantId = state.pathParameters['restaurantId']!;
        return MenuPage(restaurantId: restaurantId);
      },
    ),

    /// 🔹 Kitchen
    GoRoute(
      path: '/kitchen',
      builder: (_, __) => const KitchenDashboardPage(),
    ),

    /// 🔹 Admin
    GoRoute(
      path: '/admin',
      builder: (_, __) => const AdminDashboard(),
    ),

    GoRoute(
      path: '/admin/add',
      builder: (_, __) => const AddProductPanel(),
    ),

    /// 🔹 Orders
    GoRoute(
      path: '/orders',
      builder: (_, __) => const OrdersPage(),
    ),
  ],
);

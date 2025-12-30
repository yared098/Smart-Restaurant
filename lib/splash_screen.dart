// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/providers/config_provider.dart';
// import '../app/router.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _startApp();
//   }

//   Future<void> _startApp() async {
//     // Optional: show splash for 2 seconds
//     await Future.delayed(const Duration(seconds: 2));

//     // Navigate to the main app (router)
//     if (mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (_) => const MyAppRouterWrapper(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final config = Provider.of<ConfigProvider>(context);

//     return Scaffold(
//       backgroundColor: config.primaryColor ?? Colors.blue,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // App Logo
//             if (config.appLogo.isNotEmpty)
//               Image.network(
//                 config.appLogo,
//                 width: 120,
//                 height: 120,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
//               )
//             else
//               const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),

//             const SizedBox(height: 20),

//             // App Name
//             Text(
//               config.appName ?? 'Smart Restaurant',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Wrapper to use your router after splash
// class MyAppRouterWrapper extends StatelessWidget {
//   const MyAppRouterWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: router,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

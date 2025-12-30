import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MenuQRCodePage extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  const MenuQRCodePage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ FULL LINK (RECOMMENDED)
    final qrData = "myapp://menu/$restaurantId";
    // OR for web:
    // final qrData = "https://myapp.com/menu/$restaurantId";

    return Scaffold(
      appBar: AppBar(title: Text("$restaurantName QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan this QR code to view the menu",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250,
            ),
            const SizedBox(height: 20),
            Text(
              "Restaurant ID: $restaurantId",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

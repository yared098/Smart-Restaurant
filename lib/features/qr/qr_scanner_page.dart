import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatelessWidget {
  final String restaurantId;

  const QRGeneratorPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {

    final qrData = "myapp://menu/$restaurantId";

    return Scaffold(
      appBar: AppBar(title: const Text("Generate QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250,
              gapless: false,
            ),
            const SizedBox(height: 20),
            Text(
              "Scan this QR to open the menu for $restaurantId",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text("Copy Link"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Link copied to clipboard!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

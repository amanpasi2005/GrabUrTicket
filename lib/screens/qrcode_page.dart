import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),

      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          final String? code = barcodes.first.rawValue;

          setState(() => scanned = true);

          Navigator.pop(context, code);
        },
      ),
    );
  }
}

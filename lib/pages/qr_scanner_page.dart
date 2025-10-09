import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rtsp31_mobile/constants/vehicle_data.dart';
import 'vehicle_detail_page.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage>
    with SingleTickerProviderStateMixin {
  bool _isScanned = false;
  late AnimationController _animationController;
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    print('📱 QR Scanner initialized');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    print('🛑 QR Scanner disposed');
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null) {
      print('⚠️ Gagal membaca QR Code: rawValue null');
      return;
    }

    print('📷 QR Code terdeteksi: $code');

    _isScanned = true;
    _scannerController.stop();
    print('⛔️ Scanner dihentikan sementara');

    try {
      final vehicle = dummyVehicles.firstWhere(
        (v) => v['qr'] == code,
        orElse: () => {},
      );

      if (vehicle.isNotEmpty) {
        print(
          '✅ Data kendaraan ditemukan: ${vehicle['name']} (${vehicle['plate']})',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailPage(vehicle: vehicle),
          ),
        );
        print('🔙 Kembali dari halaman detail kendaraan');
      } else {
        print('❌ QR Code tidak cocok dengan kendaraan manapun');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kendaraan tidak ditemukan')),
        );
      }
    } catch (e) {
      print('❗ Terjadi kesalahan saat memproses QR: $e');
    }

    _isScanned = false;
    _scannerController.start();
    print('▶️ Scanner diaktifkan kembali');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Kendaraan')),
      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: 250 * _animationController.value,
                        left: 0,
                        right: 0,
                        child: Container(height: 2, color: Colors.green),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

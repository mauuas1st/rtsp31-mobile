import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/constants/vehicle_data.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';
import 'package:rtsp31_mobile/widget/build_card.dart';
import 'package:rtsp31_mobile/widget/widget_styles.dart';

class HeavyEquipmentPage extends StatefulWidget {
  const HeavyEquipmentPage({super.key});

  @override
  State<HeavyEquipmentPage> createState() => _HeavyEquipmentPageState();
}

class _HeavyEquipmentPageState extends State<HeavyEquipmentPage>
    with SingleTickerProviderStateMixin {
  int _viewIndex = 0;
  String? _idhe = '';

  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  bool _isScanned = false;
  Map<String, dynamic>? _scannedVehicle;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _scannerController = MobileScannerController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    _idhe = await SharedPrefs.getIDHE();
    final found = dummyVehicles.firstWhere(
      (v) => v['qr'] == _idhe,
      orElse: () => {},
    );
    setState(() {
      _viewIndex = (_idhe != null && _idhe!.isNotEmpty) ? 2 : 0;
      _scannedVehicle = found;
    });
  }

  void _startScan() {
    setState(() => _viewIndex = 1);
    _scannerController.start();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    if (code == null) return;

    _isScanned = true;
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 2),
    // )..repeat(reverse: true);

    try {
      final found = dummyVehicles.firstWhere(
        (v) => v['qr'] == code,
        orElse: () => {},
      );

      if (found.isNotEmpty) {
        _scannerController.stop();
        setState(() {
          _scannedVehicle = found;
          _viewIndex = 2;
        });
        await SharedPrefs.saveIDHE(code);
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('equipment_id', code);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Kendaraan tidak ditemukan')),
        // );
        _scannerController.stop();
        setState(() {
          _scannedVehicle = null;
          _viewIndex = 2;
        });
      }
    } catch (e) {
      print('❗ Terjadi kesalahan saat memproses QR: $e');
    }
    _scannerController.start();
    _isScanned = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: const Text('Heavy Equipment')),
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: IndexedStack(
            index: _viewIndex,
            children: [
              _buildInputView(),
              _buildQrScannerView(),
              _buildDetailView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // ⬅️ ini kuncinya
        mainAxisSize: MainAxisSize.min, // ⬅️ agar tidak memenuhi tinggi layar
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildCard(
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan QR ID Kendaraan"),
                    ),
                  ),
                  sizedBH(12),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: const Text(
                      "Atau cari manual disini..",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrScannerView() {
    return Stack(
      children: [
        MobileScanner(controller: _scannerController, onDetect: _onDetect),

        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: buildCard(
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("Arahkan ke QR ID Kendaraan"),
              ),
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.only(top: 40),
          //   child: Text("Scan QR Id Kendaraan"),
          // ),
        ),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                _scannerController.stop();
                setState(() {
                  _viewIndex = 0;
                  _isScanned = false;
                });
              },
              child: const Text("Batal"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    if (_scannedVehicle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ⬅️ ini kuncinya
          mainAxisSize: MainAxisSize.min, // ⬅️ agar tidak memenuhi tinggi layar
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildCard(
              Center(
                child: Text(
                  "Kendaraan Tidak di temukan, coba dengan QR ID yang lain.",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            buildCard(
              Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan QR ID Kendaraan"),
                      ),
                    ),
                    sizedBH(12),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: const Text(
                        "Atau cari manual disini..",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._scannedVehicle!.entries.where((e) => e.key != 'id').map((e) {
            String label;
            switch (e.key) {
              case 'qr':
                label = 'ID Kendaraan';
                break;
              case 'name':
                label = 'Merk';
                break;
              case 'type':
                label = 'Jenis';
                break;
              case 'plate':
                label = 'Plat Nomor';
                break;
              case 'color':
                label = 'Warna';
                break;
              default:
                label = e.key.toUpperCase();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "$label: ${e.value}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await SharedPrefs.removeIDHE();
                    setState(() => _viewIndex = 0);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    "Hapus ID Kendaraan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

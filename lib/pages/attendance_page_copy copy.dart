/* // ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rtsp31_mobile/pages/heavy_equipment.dart';
// import 'package:rtsp31_mobile/pages/qr_scanner_page.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';
import 'package:rtsp31_mobile/widget/build_card.dart';
import 'package:rtsp31_mobile/widget/photo_widget.dart';
import 'package:rtsp31_mobile/widget/widget_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendancePageCopy extends StatefulWidget {
  const AttendancePageCopy({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendancePageCopyState createState() => _AttendancePageCopyState();
}

class _AttendancePageCopyState extends State<AttendancePageCopy> {
  File? _selfiePhoto;
  File? _toolPhoto;
  String? _equipmentId;
  String _description = "";
  String? _shiftMessage;
  int _nextShift = 1;
  int? _lastAttendanceId;
  bool _isCheckIn = true;
  bool _isSubmitting = false;
  String _address = "Mengambil lokasi...";
  double? _latitude, _longitude;
  String? _idhe = '';

  final TextEditingController _equipmentController = TextEditingController();

  // final Map<String, Map<String, String>> dummyVehicles = {
  //   "EXC123": {
  //     "name": "Excavator Hitachi ZX200",
  //     "type": "Excavator",
  //     "project": "Proyek A",
  //     "status": "Aktif",
  //   },
  //   "BHL456": {
  //     "name": "Bulldozer Komatsu D65",
  //     "type": "Bulldozer",
  //     "project": "Proyek B",
  //     "status": "Maintenance",
  //   },
  // };

  @override
  void initState() {
    super.initState();
    _checkTodayAttendance();
    _loadPrefs();
    _getCurrentLocation();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // void _handleQrResult(String result) {
  //   setState(() => _equipmentId = result);
  //   _equipmentController.text = result;
  // }

  Future<void> _loadPrefs() async {
    _idhe = await SharedPrefs.getIDHE();
  }

  /*   Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    final places = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final p = places[0];
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _address =
          "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}, ${p.country}";
    });
  } */

  Future<void> _getCurrentLocation() async {
    // ✅ Minta izin lokasi via permission_handler
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Izin lokasi diperlukan.")));
      return;
    }

    // ✅ Cek apakah layanan lokasi (GPS) aktif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ❗ Di banyak HP Android, ini akan otomatis muncul dialog "Aktifkan lokasi"
      final locationOption = await Geolocator.requestPermission();
      if (locationOption == LocationPermission.denied ||
          locationOption == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Layanan lokasi tidak diaktifkan.")),
        );
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final p = placemarks[0];

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}, ${p.country}";
      });
    } catch (e) {
      debugPrint("❌ Error mengambil lokasi: $e");
    }
  }

  Future<void> _openGoogleMaps() async {
    if (_latitude == null || _longitude == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps?q=$_latitude,$_longitude',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa membuka Google Maps")),
      );
    }
  }

  Future<void> _checkTodayAttendance() async {
    final url = Uri.parse("https://rtsp31.site/api/my-attendances");
    final token = await SharedPrefs.getToken();
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'] ?? [];
      final today = DateTime.now();

      final todayAttendance =
          data.where((item) {
            final createdAt = item['created_at'];
            if (createdAt == null) return false;

            final created = DateTime.parse(createdAt).toLocal();
            return created.year == today.year &&
                created.month == today.month &&
                created.day == today.day;
          }).toList();

      debugPrint("Total data di API: ${data.length}");
      debugPrint("Data hari ini: ${todayAttendance.length}");

      if (todayAttendance.isEmpty) {
        _shiftMessage = 'Siap melakukan ritase 1 ?';
        _nextShift = 1;
        _isCheckIn = true;
      } else {
        todayAttendance.sort(
          (a, b) => DateTime.parse(
            b['created_at'],
          ).compareTo(DateTime.parse(a['created_at'])),
        );
        final latest = todayAttendance.first;
        final latestDate = DateTime.parse(latest['created_at']).toLocal();

        if (latestDate.year != today.year ||
            latestDate.month != today.month ||
            latestDate.day != today.day) {
          _shiftMessage = 'Siap melakukan ritase 1 hari ini ?';
          _nextShift = 1;
          _isCheckIn = true;
        } else {
          _nextShift = latest['shift'];
          if (latest['check_out_time'] == null) {
            _isCheckIn = false;
            _lastAttendanceId = latest['id'];
            _shiftMessage = 'Ritase $_nextShift dalam proses...!';
          } else {
            _isCheckIn = true;
            _nextShift += 1;
            _shiftMessage = 'Lanjut ritase $_nextShift ?';
          }
        }
      }

      setState(() {});
    } else {
      debugPrint("Gagal ambil data: ${response.statusCode}");
    }
  }

  Future<void> _pickImage(bool isSelfie) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isSelfie) {
          _selfiePhoto = File(picked.path);
        } else {
          _toolPhoto = File(picked.path);
        }
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_selfiePhoto == null || _toolPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon ambil kedua foto terlebih dahulu."),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final token = await SharedPrefs.getToken();
    final uri = Uri.parse(
      _isCheckIn
          ? "https://rtsp31.site/api/my-attendances/check-in"
          : "https://rtsp31.site/api/my-attendances/check-out",
    );

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    final now = DateTime.now();
    final time = "${now.hour}:${now.minute}:${now.second}";

    if (!_isCheckIn) {
      request.fields['_method'] = 'PUT';
    }

    request.fields.addAll({
      if (_isCheckIn) ...{
        "check_in_time": time,
        "work_location": "office",
        "latitude_in": "-6.2",
        "longitude_in": "106.8",
        "check_in_address": "Dummy Street",
        "check_in_map_link": "https://maps.example.com",
        "project_name": "Test Project",
        "heavy_equipment_id": "EXC123",
        "check_in_note": "-",
      } else ...{
        "check_out_time": time,
        "latitude_out": "-6.2",
        "longitude_out": "106.8",
        "check_out_address": "Dummy Street",
        "check_out_map_link": "https://maps.example.com",
        "check_out_note": "-",
      },
    });

    // ✅ Tambah file foto
    request.files.add(
      await http.MultipartFile.fromPath(
        _isCheckIn ? 'check_in_photo' : 'check_out_photo',
        _selfiePhoto!.path,
      ),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        _isCheckIn ? 'check_in_tool_photo' : 'check_out_tool_photo',
        _toolPhoto!.path,
      ),
    );

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    setState(() => _isSubmitting = false);

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil absensi!")));
      }
      _selfiePhoto = null;
      _toolPhoto = null;
      await _checkTodayAttendance();
      setState(() {});
    } else {
      if (kDebugMode) {
        print("Gagal: ${resp.body}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_shiftMessage != null)
                    buildCard(
                      Center(
                        child: Text(
                          _shiftMessage!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  sizedBH(2),

                  buildCard(
                    Row(
                      children: [
                        Expanded(
                          child: buildPhotoBox(
                            "Foto Selfie",
                            _selfiePhoto,
                            () => _pickImage(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildPhotoBox(
                            "Foto Kendaraan",
                            _toolPhoto,
                            () => _pickImage(false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sizedBH(2),

                  buildCard(
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HeavyEquipmentPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Id Kendaraan : $_idhe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  sizedBH(2),

                  // buildCard(
                  //   Padding(
                  //     padding: const EdgeInsets.all(12),
                  //     child: Column(
                  //       children: [
                  //         SizedBox(
                  //           width: double.infinity,
                  //           child: ElevatedButton.icon(
                  //             onPressed: () async {
                  //               final result = await Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) => QrScanPage(),
                  //                 ),
                  //               );
                  //               if (result != null && result is String) {
                  //                 _handleQrResult(result);
                  //               }
                  //             },
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor: Colors.white,
                  //               foregroundColor: Colors.black,
                  //               elevation: 2,
                  //               side: const BorderSide(color: Colors.grey),
                  //               padding: const EdgeInsets.symmetric(
                  //                 horizontal: 16,
                  //                 vertical: 16,
                  //               ),
                  //               shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(8),
                  //               ),
                  //             ),
                  //             icon: const Icon(Icons.qr_code_scanner),
                  //             label: const Text("Scan QR ID Kendaraan"),
                  //           ),
                  //         ),
                  //         sizedBH(4),
                  //         const Text(
                  //           "Atau",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 16,
                  //           ),
                  //           textAlign: TextAlign.center,
                  //         ),
                  //         sizedBH(4),
                  //         SizedBox(
                  //           width: double.infinity,
                  //           child: TextField(
                  //             controller: _equipmentController,
                  //             decoration: const InputDecoration(
                  //               labelText: "Masukkan ID Kendaraan",
                  //               border: OutlineInputBorder(),
                  //             ),
                  //             onChanged: (val) => _equipmentId = val,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // sizedBH(2),
                  buildCard(
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_pin),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _openGoogleMaps,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _address,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: _openGoogleMaps,
                                      child: const Text(
                                        'lihat di peta',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  sizedBH(2),
                  buildCard(
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Keterangan",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        onChanged: (v) => _description = v,
                      ),
                    ),
                  ),
                  sizedBH(2),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
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
                          onPressed: _submitAttendance,
                          icon: const Icon(Icons.send),
                          label: const Text("Simpan"),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */

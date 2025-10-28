/* import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rtsp31_mobile/constants/api_constants.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/pages/attendance_page_copy.dart';
// import 'package:rtsp31_mobile/pages/form_absens.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';
import 'package:rtsp31_mobile/widget/widget_styles.dart'; // untuk colorPrimary()

class AbsenAndMaps extends StatefulWidget {
  const AbsenAndMaps({super.key});

  @override
  State<AbsenAndMaps> createState() => _AbsenAndMapsState();
}

class _AbsenAndMapsState extends State<AbsenAndMaps> {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  Marker? _userLocationMarker;
  Timer? _gpsTimer;
  bool _autoCenter = true;

  final LatLng _center = LatLng(-5.4093, 105.2750);
  final double _zoom = 15.0;

  String _mapType = 'Map';
  final GlobalKey _menuKey = GlobalKey();
  List<Marker> _otherMarkers = [];

  bool shift1MasukDone = false;
  bool shift1KeluarDone = false;
  bool shift2MasukDone = false;
  bool shift2KeluarDone = false;

  String _token = '', _userId = '';

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs().then((_) {
      _startLiveLocation();
      _fetchOtherMarkers();
      // _checkTodayAbsensi();
    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _loadSharedPrefs() async {
    int? userId = await SharedPrefs.getUserId();
    String? token = await SharedPrefs.getToken();
    setState(() {
      _userId = userId?.toString() ?? '';
      _token = token ?? '';
    });
  }

  // Future<void> _checkTodayAbsensi() async {
  //   final now = DateTime.now();
  //   final today =
  //       "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  //   try {
  //     final res = await http.get(
  //       Uri.parse('${ApiConstants.absensi}/$_userId?date=$today'),
  //       headers: {
  //         'Authorization': 'Bearer $_token',
  //         'Accept': 'application/json',
  //       },
  //     );
  //     if (res.statusCode == 200) {
  //       final data = jsonDecode(res.body)['data'];
  //       setState(() {
  //         shift1MasukDone = data['shift_1']['jam_masuk'] != null;
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("⚠️ Error fetch absensi: $e");
  //     }
  //   }
  // }

  Future<void> _fetchOtherMarkers() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.liveGps),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        setState(() {
          _otherMarkers =
              list.map((item) {
                final lat = double.tryParse(item['latitude'].toString()) ?? 0;
                final lng = double.tryParse(item['longitude'].toString()) ?? 0;
                final name = item['employee_id'] ?? '';
                final addr = item['address'] ?? '';
                return Marker(
                  point: LatLng(lat, lng),
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: () => _showMarkerPopup(context, name, addr),
                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                );
              }).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Error other markers: $e");
      }
    }
  }

  Future<void> _startLiveLocation() async {
    if (!await Permission.location.request().isGranted) return;

    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final pos = await Geolocator.getCurrentPosition();
      final lat = pos.latitude, lng = pos.longitude;
      final list = await placemarkFromCoordinates(lat, lng);
      final addr =
          list.isNotEmpty
              ? "${list.first.street}, ${list.first.locality}"
              : "Unknown location";

      await http.post(
        Uri.parse(ApiConstants.liveGps),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "user_id": _userId,
          "employee_id": "EMP123",
          "heavy_equipment_id": "EXC123",
          "project_name": "Test Project",
          "latitude": lat,
          "longitude": lng,
          "address": addr,
          "location_map_link": "https://maps.google.com/?q=$lat,$lng",
          "power": true,
        }),
      );

      _userLocation = LatLng(lat, lng);
      _userLocationMarker = Marker(
        point: _userLocation!,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.person_pin_circle,
          size: 40,
          color: Colors.green,
        ),
      );

      if (_autoCenter) {
        _mapController.move(_userLocation!, _zoom);
      }
      if (kDebugMode) {
        print("Sending GPS: user_id=$_userId, token=$_token");
      }
      _fetchOtherMarkers();
    });
  }

  void _stopGps() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  void _showMarkerPopup(BuildContext cx, String title, String desc) {
    showDialog(
      context: cx,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(desc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(cx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _stopGps();
    super.dispose();
  }

  void _onMapTypePressed() async {
    final rb = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;

    final off = rb.localToGlobal(Offset.zero);
    final size = rb.size;

    final sel = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        off.dx,
        off.dy + size.height,
        off.dx + size.width,
        off.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'Map',
          child: Text(
            'Peta',
            style: TextStyle(
              fontWeight:
                  _mapType == 'Map' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Satellite',
          child: Text(
            'Satelit',
            style: TextStyle(
              fontWeight:
                  _mapType == 'Satellite' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
    if (sel != null && sel != _mapType) setState(() => _mapType = sel);
  }

  Widget _buildShiftRow(int s, bool masuk, bool keluar) {
    bool bisaMasuk = !masuk;
    // bool bisaKeluar = masuk && !keluar;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: Card(
            color: AppColors.colorPrimary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: bisaMasuk ? () => _onShiftMasuk(s) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "Mulai",
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          width: 150, // contoh lebar 250
          child: Card(
            color: Colors.red,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _onShiftKeluar();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "Stop",
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onShiftMasuk(int s) {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => FormAbsenPage(shift: s, isKeluar: false)))
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AttendancePageCopy()),
    );
    // .then((_) => _checkTodayAbsensi());
  }

  void _onShiftKeluar() {
    _stopGps();
    // .then((_) => _checkTodayAbsensi());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(child: _buildMapStack()),
            sizedBH(12),
            _buildShiftRow(1, shift1MasukDone, shift1KeluarDone),
            sizedBH(12),
          ],
        ),
      ),
    );
  }

  Widget _buildMapStack() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: _zoom,
            onPositionChanged: (p, h) {
              if (h) setState(() => _autoCenter = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  _mapType == 'Map'
                      ? 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
                      : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.rtsp31.site',
              tileProvider: NetworkTileProvider(),
            ),
            MarkerLayer(
              markers: [
                ..._otherMarkers,
                if (_userLocationMarker != null) _userLocationMarker!,
              ],
            ),
          ],
        ),
        Positioned(
          top: 10,
          left: 10,
          child: _buildCircleIcon(
            Icons.arrow_back,
            () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _buildCircleIcon(
            Icons.layers_outlined,
            _onMapTypePressed,
            key: _menuKey,
          ),
        ),
        Positioned(
          right: 10,
          bottom: 70,
          child: _buildCircleIcon(Icons.my_location, () {
            if (_userLocation != null) {
              _mapController.move(_userLocation!, _zoom);
              setState(() => _autoCenter = true);
            }
          }, isFab: true),
        ),
      ],
    );
  }

  Widget _buildCircleIcon(
    IconData icon,
    VoidCallback onTap, {
    Key? key,
    bool isFab = false,
  }) {
    if (isFab) {
      return FloatingActionButton(
        key: key,
        mini: true,
        backgroundColor: Colors.white,
        onPressed: onTap,
        child: Icon(icon, color: Colors.black),
      );
    } else {
      return Container(
        key: key,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: IconButton(icon: Icon(icon), onPressed: onTap),
      );
    }
  }
}
 */

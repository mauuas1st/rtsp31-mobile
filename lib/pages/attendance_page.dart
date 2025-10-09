/* import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rtsp31_mobile/utils/shared_prefs.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  File? _selfiePhoto;
  File? _toolPhoto;

  String? _shiftMessage;
  int _nextShift = 1;
  // ignore: unused_field
  int? _lastAttendanceId;
  bool _isCheckIn = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkTodayAttendance();
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
        _shiftMessage = 'Belum ada shift. Siap untuk Shift 1 (Check-in)';
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
          _shiftMessage =
              'Belum ada shift hari ini. Siap untuk Shift 1 (Check-in)';
          _nextShift = 1;
          _isCheckIn = true;
        } else {
          _nextShift = latest['shift'];
          if (latest['check_out_time'] == null) {
            _isCheckIn = false;
            _lastAttendanceId = latest['id'];
            _shiftMessage = 'Shift $_nextShift belum Check-out.';
          } else {
            _isCheckIn = true;
            _nextShift += 1;
            _shiftMessage = 'Siap untuk Shift $_nextShift (Check-in)';
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

    // ✅ Gunakan POST meskipun update, dan override method dengan _method=PUT
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    final now = DateTime.now();
    final time = "${now.hour}:${now.minute}:${now.second}";

    // ✅ Tambahkan _method PUT jika sedang Check-Out
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
        appBar: AppBar(title: Text("Absensi")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_shiftMessage != null)
                Text(_shiftMessage!, style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text("Selfie"),
                        _selfiePhoto != null
                            ? Image.file(_selfiePhoto!, height: 100)
                            : const Text("Belum ada foto"),
                        ElevatedButton(
                          onPressed: () => _pickImage(true),
                          child: const Text("Ambil Selfie"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Foto Alat"),
                        _toolPhoto != null
                            ? Image.file(_toolPhoto!, height: 100)
                            : const Text("Belum ada foto"),
                        ElevatedButton(
                          onPressed: () => _pickImage(false),
                          child: const Text("Ambil Foto Alat"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submitAttendance,
                    child: Text("Kirim Absensi"),
                  ),

              Text(
                _isCheckIn
                    ? "Status: Siap untuk Check-In"
                    : "Status: Sudah Check-In, Silakan Check-Out",
                style: TextStyle(
                  color: _isCheckIn ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 */

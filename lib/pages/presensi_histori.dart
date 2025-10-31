import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/models/presensi.dart';
import 'package:rtsp31_mobile/pages/attendance_page_copy.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';

class PresensiHistori extends StatefulWidget {
  const PresensiHistori({super.key});

  @override
  State<PresensiHistori> createState() => _PresensiHistoriState();
}

class _PresensiHistoriState extends State<PresensiHistori> {
  PresensiModel? firstItem;
  List<PresensiModel> attendances = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchFirstAttendance();
    fetchAttendances(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 120 &&
          !isLoading &&
          hasMore) {
        fetchAttendances();
      }
    });
  }

  Future<void> fetchFirstAttendance() async {
    final token = await SharedPrefs.getToken();
    final response = await http.get(
      Uri.parse(
        'http://192.168.100.251:8000/api/v1/my-attendances/today?page=1',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] as List;
      if (data.isNotEmpty) {
        setState(() {
          firstItem = PresensiModel.fromJson(data.first);
        });
      }
    }
  }

  Future<void> fetchAttendances({bool isRefresh = false}) async {
    if (!isRefresh && (isLoading || !hasMore)) return;

    if (!isRefresh) {
      setState(() => isLoading = true);
    }

    try {
      final token = await SharedPrefs.getToken();
      final response = await http.get(
        Uri.parse(
          'http://192.168.100.251:8000/api/v1/my-attendances/today?page=$currentPage',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final meta = body['meta'];
        final cur = meta?['current_page'] ?? currentPage;
        final last = meta?['last_page'] ?? cur;

        setState(() {
          attendances.addAll(
            (body['data'] as List)
                .map((e) => PresensiModel.fromJson(e))
                .toList(),
          );
          hasMore = cur < last;
          if (hasMore) currentPage++;
        });
      }
    } catch (e) {
      // tangani exception jika perlu
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> refreshData() async {
    setState(() {
      attendances.clear();
      currentPage = 1;
      hasMore = true;
      isLoading = true;
    });

    await fetchFirstAttendance();
    await fetchAttendances(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // ---------------- Top Card ----------------
            buildTopCard(context, firstItem),

            const SizedBox(height: 12),

            // ---------------- Riwayat ----------------
            Expanded(
              child: RefreshIndicator(
                onRefresh: refreshData,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Riwayat",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: 16,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Builder(
                              builder: (_) {
                                if (isLoading && attendances.isEmpty) {
                                  // ---------------- Skeleton awal ----------------
                                  return ListView.builder(
                                    itemCount: 6,
                                    itemBuilder:
                                        (context, index) => buildSkeletonItem(),
                                  );
                                } else if (!isLoading && attendances.isEmpty) {
                                  // ---------------- Belum ada data ----------------
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.history,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          "Belum ada kehadiran",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // ---------------- Data ada + infinite scroll ----------------
                                  return ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        attendances.length +
                                        (isLoading ? 3 : 0),
                                    itemBuilder: (context, index) {
                                      if (index < attendances.length) {
                                        return buildRiwayatItem(
                                          attendances[index],
                                        );
                                      } else {
                                        return buildSkeletonItem();
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Riwayat Item ----------------
  Widget buildRiwayatItem(PresensiModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.workLocation,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Mulai: ${item.checkInTime != null ? DateFormat('HH:mm').format(item.checkInTime!) : "-"} WIB",
              ),
              Text(
                "Selesai: ${item.checkOutTime != null ? DateFormat('HH:mm').format(item.checkOutTime!) : "-"} WIB",
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${item.employeeId} - ',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (item.checkInTime != null)
                    Text(
                      DateFormat('dd MMMM yyyy').format(item.checkInTime!),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Skeleton Item ----------------
  Widget buildSkeletonItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        color: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 100, height: 14, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 6),
              Container(width: 140, height: 14, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- TopCardWidget ----------------
Widget buildTopCard(BuildContext context, PresensiModel? firstItem) {
  final now = DateTime.now();
  final checkInTime = firstItem?.checkInTime ?? now;
  final checkOutTime = firstItem?.checkOutTime ?? now;

  String calculateDuration() {
    if (firstItem?.checkInTime == null || firstItem?.checkOutTime == null) {
      return '0 jam';
    }
    final duration = checkOutTime.difference(checkInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours jam $minutes menit';
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                DateFormat('dd MMMM yyyy').format(checkInTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${firstItem?.checkInTime != null ? DateFormat('HH:mm').format(checkInTime) : '00:00'} - '
                '${firstItem?.checkOutTime != null ? DateFormat('HH:mm').format(checkOutTime) : '00:00'}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Jam Kerja : ${calculateDuration()}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 250,
                child: Card(
                  color: AppColors.colorPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: const Text(
                      "Tugas",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AttendancePageCopy(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

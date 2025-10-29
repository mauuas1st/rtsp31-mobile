import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/models/presensi.dart';
import 'package:rtsp31_mobile/pages/attendance_page_copy.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';
import 'package:rtsp31_mobile/widget/widget_presensi.dart';
import 'package:rtsp31_mobile/widget/widget_styles.dart';

class PresensiHistori extends StatefulWidget {
  const PresensiHistori({super.key});

  @override
  State<PresensiHistori> createState() => _PresensiHistoriState();
}

class _PresensiHistoriState extends State<PresensiHistori> {
  final ScrollController _scrollController = ScrollController();

  List<PresensiModel> attendances = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 120 &&
          !isLoading &&
          hasMore) {
        fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    final token = await SharedPrefs.getToken();

    final response = await http.get(
      Uri.parse(
        'http://192.168.18.14:8000/api/v1/my-attendances/today?page=$currentPage',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      attendances.addAll(
        (body['data'] as List).map((e) => PresensiModel.fromJson(e)).toList(),
      );

      final meta = body['meta'];
      final cur = meta?['current_page'] ?? currentPage;
      final last = meta?['last_page'] ?? cur;
      final nextUrl = body['links']?['next'];

      setState(() {
        hasMore = nextUrl != null && cur < last;
        if (hasMore) currentPage++;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> refreshData() async {
    setState(() {
      attendances.clear();
      currentPage = 1;
      hasMore = true;
    });
    await fetchData();
  }

  Widget buildTodayTopCard() {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              DateFormat('dd MMMM yyyy').format(now),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '00:00 - 00:00',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Total Jam Kerja : -'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = attendances.isNotEmpty ? attendances.first : null;

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ✅ jika tidak ada data = gunakan topCard kosong
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      firstItem != null
                          ? buildTopCard(context, firstItem)
                          : buildTodayTopCard(),
                ),

                const SizedBox(height: 25),

                // ✅ Riwayat List - kondisi kosong ditangani di dalam widget
                buildRiwayatList(
                  context: context,
                  attendances: attendances,
                  scrollController: _scrollController,
                  isLoading: isLoading,
                ),

                sizedBH(50),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.grey[100],
      ),
    );
  }
}

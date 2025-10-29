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
        'http://192.168.100.2:8000/api/v1/my-attendances?page=$currentPage',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List<dynamic> raw = body['data'];
      attendances.addAll(
        raw.map((e) => PresensiModel.fromJson(e as Map<String, dynamic>)),
      );

      final meta = body['meta'];
      final cur = meta?['current_page'] ?? currentPage;
      final last = meta?['last_page'] ?? cur;
      final nextUrl = body['links']?['next'];

      setState(() {
        hasMore = nextUrl != null && cur < last;
        if (hasMore) currentPage++;
      });
    } else {
      debugPrint('Fetch gagal – ${response.statusCode}');
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstItem = attendances.isNotEmpty ? attendances.first : null;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: RefreshIndicator(
          onRefresh: refreshData,
          child:
              attendances.isEmpty && !isLoading
                  ? _buildEmptyView(now)
                  : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        if (firstItem != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: buildTopCard(context, firstItem),
                          ),
                        const SizedBox(height: 25),
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
      ),
    );
  }

  Widget _buildEmptyView(DateTime now) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 14),
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
          const Text('Total Jam Kerja : -', style: TextStyle(fontSize: 14)),
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
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text("Data presensi tidak tersedia"),
            ],
          ),
        ],
      ),
    );
  }
}

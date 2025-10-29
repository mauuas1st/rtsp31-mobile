// ignore: unnecessary_import
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:rtsp31_mobile/constants/app_color.dart';
// import 'package:rtsp31_mobile/pages/absensi_lokasi_maps.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rtsp31_mobile/models/presensi.dart';
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
      // Trigger ketika hampir mentok scroll & masih ada halaman berikutnya
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

      // 1) Tambah data baru
      final List<dynamic> raw = body['data'] as List<dynamic>;
      final newItems = raw.map(
        (e) => PresensiModel.fromJson(e as Map<String, dynamic>),
      );

      setState(() => attendances.addAll(newItems));

      // 2) Cek apakah masih ada halaman selanjutnya
      final String? nextUrl = body['links']?['next'];
      //  –atau– pakai meta:
      final int cur = body['meta']?['current_page'] ?? currentPage;
      final int last = body['meta']?['last_page'] ?? cur;

      setState(() {
        hasMore = nextUrl != null && cur < last;
        if (hasMore) currentPage++; // naikkan page kalau memang ada next
      });
    } else {
      // Optional: tampilkan snackbar / dialog kesalahan
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
    PresensiModel? firstItem;
    if (attendances.isNotEmpty) {
      firstItem = attendances[0];
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: RefreshIndicator(
          onRefresh: refreshData,
          child:
              attendances.isEmpty && !isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Data presensi tidak tersedia"),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        if (attendances.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: buildTopCard(context, firstItem!),
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
}

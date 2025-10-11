// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/pages/absensi_lokasi_maps.dart';
import 'package:rtsp31_mobile/pages/attendance_page.dart';
import 'package:rtsp31_mobile/pages/attendance_page_copy.dart';
import 'package:rtsp31_mobile/pages/heavy_equipment.dart';
import 'package:rtsp31_mobile/utils/keep_alive_page.dart';
// import 'package:rtsp31_mobile/pages/notifikasi.dart';
import 'package:rtsp31_mobile/pages/presensi_histori.dart';
import 'package:rtsp31_mobile/pages/profil_page.dart';
import 'package:rtsp31_mobile/pages/form_absens.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  late PageController _pageController;
  DateTime timeBackPressed = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // atau Colors.white kalau ingin putih
        statusBarIconBrightness:
            Brightness.dark, // supaya iconnya terlihat di latar terang
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool canPop) {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= const Duration(seconds: 2);
        timeBackPressed = DateTime.now();
        const message = 'Tekan sekali lagi untuk keluar';

        if (isExitWarning) {
          Fluttertoast.showToast(msg: message, fontSize: 18);
        } else {
          Fluttertoast.cancel();
          SystemNavigator.pop(); // Exit from app......
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            const KeepAlivePage(child: PresensiHistori()),
            // const KeepAlivePage(child: AbsenAndMaps()),
            // const KeepAlivePage(child: HeavyEquipmentPage()),
            // const KeepAlivePage(child: FormAbsenPage(title: 'Test')),
            // const KeepAlivePage(child: NotifPage()),
            // const KeepAlivePage(child: PresensiHistori()),
            const KeepAlivePage(child: ProfilePage()),
          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.colorPrimary,
          unselectedItemColor: AppColors.colorPrimary,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          items: _navBarItems,
        ),
      ),
    );
  }
}

// Data untuk SalomonBottomBarItem
final _navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    title: const Text("Presensi"),
    selectedColor: AppColors.colorPrimary,
  ),
  // SalomonBottomBarItem(
  //   icon: const Icon(Icons.gps_fixed_sharp),
  //   title: const Text("Gps"),
  //   selectedColor: AppColors.colorPrimary,
  // ),
  // SalomonBottomBarItem(
  //   icon: const Icon(Icons.car_rental),
  //   title: const Text("Kendaraan"),
  //   selectedColor: AppColors.colorPrimary,
  // ),
  // SalomonBottomBarItem(
  //   icon: const Icon(Icons.search),
  //   title: const Text("Search"),
  //   selectedColor: colorPrimary(),
  // ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: const Text("Profil"),
    selectedColor: AppColors.colorPrimary,
  ),
];

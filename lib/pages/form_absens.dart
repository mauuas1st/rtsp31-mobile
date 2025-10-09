/* // ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';
import 'package:rtsp31_mobile/widget/build_card.dart';
import 'package:rtsp31_mobile/widget/photo_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Category {
  final String id, name;
  Category({required this.id, required this.name});
}

class FormAbsenPage extends StatefulWidget {
  final String title;
  const FormAbsenPage({super.key, required this.title});

  @override
  State<FormAbsenPage> createState() => _FormAbsenPageState();
}

class _FormAbsenPageState extends State<FormAbsenPage> {
  File? _selfiePhoto, _surroundingPhoto;
  String _address = "Mengambil lokasi...";
  double? _latitude, _longitude;
  String _description = "";
  Category? _selectedCategory;
  String? _idhe = '';

  final List<Category> _categories = List.generate(
    5,
    (i) => Category(id: "${i + 1}", name: "Excavator ${i + 1}"),
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadPrefs();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _loadPrefs() async {
    _idhe = await SharedPrefs.getIDHE();
  }

  Future<void> _pickImage(bool isSelfie) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: isSelfie ? CameraDevice.front : CameraDevice.rear,
    );
    if (picked != null) {
      setState(
        () =>
            isSelfie
                ? _selfiePhoto = File(picked.path)
                : _surroundingPhoto = File(picked.path),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildCard(
                Row(
                  children: [
                    Expanded(
                      child: buildPhotoBox(
                        "Foto Selfie*",
                        _selfiePhoto,
                        () => _pickImage(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildPhotoBox(
                        "Foto Alat*",
                        _surroundingPhoto,
                        () => _pickImage(false),
                      ),
                    ),
                  ],
                ),
              ),
              buildCard(
                Center(
                  child: Text(
                    'Id Kendaraan : $_idhe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              buildCard(
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  hint: const Text('Pilih Alat'),
                  items:
                      _categories
                          .map(
                            (c) =>
                                DropdownMenuItem(value: c, child: Text(c.name)),
                          )
                          .toList(),
                  onChanged: (c) => setState(() => _selectedCategory = c),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.car_repair_outlined),
                  ),
                ),
              ),
              buildCard(
                Row(
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
              buildCard(
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Keterangan",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onChanged: (v) => _description = v,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: AppColors.colorPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */

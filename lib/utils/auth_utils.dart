import 'dart:async';
import 'dart:convert';
import 'dart:io'; // untuk SocketException
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rtsp31_mobile/constants/api_constants.dart';
import 'package:rtsp31_mobile/models/user_models.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';

class AuthUtils {
  /// 🔹 Login user dan simpan token + data user ke SharedPreferences
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10)); // ⏱ timeout agar tidak hang

      if (kDebugMode) {
        print('🔹 Login response: ${response.statusCode} => ${response.body}');
      }

      Map<String, dynamic>? body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null; // jika bukan JSON
      }

      if (response.statusCode == 200 && body?['token'] != null) {
        final token = body!['token'];
        await SharedPrefs.saveToken(token);

        // 🔹 Ambil data user dari endpoint /api/user
        final userRes = await http.get(
          Uri.parse(ApiConstants.user),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (kDebugMode) {
          print(
            '🔹 Fetch user response: ${userRes.statusCode} => ${userRes.body}',
          );
        }

        if (userRes.statusCode == 200 && userRes.body.isNotEmpty) {
          final userJson = jsonDecode(userRes.body);
          if (userJson['user'] != null) {
            final user = UserModels.fromJson(userJson['user']);
            await SharedPrefs.saveUserId(user.id);
            await SharedPrefs.saveName(user.name);
            await SharedPrefs.saveEmail(user.email);
            await SharedPrefs.saveRole(user.roleId);
          }
        }

        return null; // ✅ Login sukses
      } else {
        // ⚠️ Ambil pesan dari API jika ada
        final apiMessage = body?['message'] ?? body?['error'];
        return apiMessage ?? 'Email atau kata sandi salah.';
      }
    } on SocketException {
      return 'Terjadi kesalahan pada jaringan anda. Silakan coba lagi.';
    } on TimeoutException {
      return 'Koneksi ke server terlalu lama. Silakan coba lagi.';
    } catch (e) {
      if (kDebugMode) print('❌ Login error: $e');
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  static Future<bool> checkToken(String token) async {
    return token.isNotEmpty;
  }

  /// 🔹 Logout user dari server dan hapus data lokal
  static Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logout),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print(
          response.statusCode == 200
              ? '✅ Logout sukses dari API'
              : '⚠️ Logout gagal: ${response.body}',
        );
      }

      await SharedPrefs.clearAll();
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('❌ Logout error: $e');
      await SharedPrefs.clearAll();
      return false;
    }
  }

  /// 🔹 Ambil data user dari token (tanpa login ulang)
  static Future<UserModels?> fetchUser(String token) async {
    try {
      final url = Uri.parse(ApiConstants.user);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print(
          '🔹 Fetch user response: ${response.statusCode} => ${response.body}',
        );
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['user'] != null) {
          return UserModels.fromJson(jsonData['user']);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Fetch user error: $e');
      return null;
    }
  }
}

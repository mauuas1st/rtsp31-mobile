import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rtsp31_mobile/constants/api_constants.dart';
import 'package:rtsp31_mobile/models/user_models.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';

class AuthUtils {
  /// 🔹 Login user dan simpan token + data user ke SharedPreferences
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiConstants.login);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      final body = json.decode(response.body);

      if (kDebugMode) {
        print('🔹 Login response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode == 200 && body['token'] != null) {
        final token = body['token'];
        await SharedPrefs.saveToken(token);

        // 🔹 Ambil data user
        final userRes = await http.get(
          Uri.parse(ApiConstants.user),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (userRes.statusCode == 200) {
          final userBody = json.decode(userRes.body);
          if (userBody['user'] != null) {
            final user = UserModels.fromJson(userBody['user']);
            await SharedPrefs.saveUserId(user.id);
            await SharedPrefs.saveName(user.name);
            await SharedPrefs.saveEmail(user.email);
            await SharedPrefs.saveRole(user.roleId);
          }
        }

        return {
          'success': true,
          'message': body['message'] ?? 'Login berhasil',
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Email atau kata sandi salah',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Periksa koneksi Anda.',
      };
    } catch (e) {
      if (kDebugMode) print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  static Future<bool> checkToken(String token) async {
    return token.isNotEmpty;
  }

  static Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logout),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      await SharedPrefs.clearAll();
      return response.statusCode == 200;
    } catch (e) {
      await SharedPrefs.clearAll();
      return false;
    }
  }

  static Future<UserModels?> fetchUser(String token) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.user),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['user'] != null) {
          return UserModels.fromJson(data['user']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

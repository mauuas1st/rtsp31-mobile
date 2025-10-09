import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<void> saveIDHE(String idhe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idhe', idhe);
  }

  static Future<String?> getIDHE() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idhe');
  }

  static Future<void> removeIDHE() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idhe');
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  static Future<void> removeName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<void> removeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
  }

  static Future<void> saveRole(int role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('role', role);
  }

  static Future<int?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('role');
  }

  static Future<void> removeRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Untu Simpan 
// await SharedPrefs.saveToken('your_token_here');
// Untu Ambil 
// String? token = await SharedPrefs.getToken();

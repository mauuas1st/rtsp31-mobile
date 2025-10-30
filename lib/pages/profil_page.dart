import 'package:flutter/material.dart';
import 'package:rtsp31_mobile/models/user_models.dart';
import 'package:rtsp31_mobile/utils/auth_utils.dart';
import 'package:rtsp31_mobile/utils/shared_prefs.dart';
import 'package:rtsp31_mobile/pages/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModels?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<UserModels?> _loadUser() async {
    final token = await SharedPrefs.getToken();
    if (token == null) return null;
    return await AuthUtils.fetchUser(token);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: FutureBuilder<UserModels?>(
          future: _userFuture,
          builder: (context, snapshot) {
            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const Center(child: CircularProgressIndicator());
            } else {
              final user = snapshot.data;

              content = Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (user != null) ...[
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc',
                          // 'http://192.168.100.251:8000/storage/foto/${user.photo}',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
                      const Text(
                        'Data user tidak tersedia',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),
                    ],
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text('Yakin ingin logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm ?? false) {
                            final token = await SharedPrefs.getToken();

                            // Jika data user ada dan token ada, panggil API logout
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                token != null) {
                              await AuthUtils.logout(token);
                            }

                            // Hapus semua SharedPreferences
                            await SharedPrefs.clearAll();

                            // Kembali ke LoginScreen
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return content;
          },
        ),
      ),
    );
  }
}

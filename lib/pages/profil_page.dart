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

  Widget buildSkeletonProfile() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Skeleton Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(height: 20),

          // Skeleton Nama
          Container(
            height: 18,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: 12),

          // Skeleton Email
          Container(
            height: 18,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: 40),

          // Skeleton Logout Button
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: FutureBuilder<UserModels?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildSkeletonProfile(); // ✅ Skeleton Loading
            }

            final user = snapshot.data;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  if (user != null) ...[
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage('https://i.pravatar.cc'),
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
                          if (snapshot.data != null && token != null) {
                            await AuthUtils.logout(token);
                          }
                          await SharedPrefs.clearAll();
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
          },
        ),
      ),
    );
  }
}

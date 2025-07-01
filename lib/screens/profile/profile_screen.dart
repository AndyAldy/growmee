import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Tambahkan import ini
import '../../controllers/user_controller.dart';
import '../../theme/theme_provider.dart';
import '../../utils/user_session.dart';
import '../../widgets/nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Menggunakan microtask untuk memastikan context tersedia
    Future.microtask(() {
      final session = Get.find<UserSession>();
      final userId = session.userId.value;
      if (userId.isNotEmpty) {
        // Menggunakan listen: false di initState
        Provider.of<UserController>(context, listen: false).fetchUserData(userId);
      }
    });
  }

  // --- FUNGSI LOGOUT YANG DIPERBAIKI ---
  void _logout() async {
    // Ambil userId SEBELUM session di-clear
    final session = Get.find<UserSession>();
    final userId = session.userId.value;

    // 1. Sign out dari Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // 2. Bersihkan data sesi lokal
    session.clear();

    // 3. Arahkan ke halaman login dan kirim userId terakhir
    //    agar bisa menampilkan opsi login sidik jari.
    Get.offAllNamed('/login', arguments: {'userId': userId});
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer agar widget rebuild saat data berubah
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final user = userController.userModel;

        return Scaffold(
          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 60, bottom: 30),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary.withOpacity(0.7)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              const CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                user.name ?? 'Pengguna',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Aktifkan Login dengan Fingerprint'),
                          secondary: const Icon(Icons.fingerprint),
                          value: user.fingerprintEnabled,
                          onChanged: (value) async {
                            await userController.updateFingerprintStatus(user.uid, value);
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Tema Gelap'),
                          secondary: const Icon(Icons.dark_mode),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                        ),
                        const Divider(),
                      ],
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Keluar',
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: const NavBar(currentIndex: 3),
        );
      },
    );
  }
}

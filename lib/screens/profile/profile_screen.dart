import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'package:growmee/utils/user_session.dart';
import 'package:growmee/widgets/nav_bar.dart';
import '../../screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Memuat data saat screen pertama kali dibangun
    Future.microtask(() {
      final session = Get.find<UserSession>();
      final userId = session.userId.value;
      if (userId.isNotEmpty) {
        Provider.of<UserController>(context, listen: false).fetchUserData(userId);
      }
    });
  }

  void _logout() {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya",
      textCancel: "Tidak",
      onConfirm: () {
        final session = Get.find<UserSession>();
        session.clear();
        Get.offAll(() => const LoginScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        final user = userController.userModel;

        return Scaffold(
          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
                        // Container header tetap sama
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 60, bottom: 30),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.lightBlue],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.only(
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
                                user.name ?? 'Tanpa Nama',
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
                        const SizedBox(height: 40),

                        // List info user tetap sama
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Nama Lengkap'),
                          subtitle: Text(user.name ?? '-'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        const Divider(),

                        SwitchListTile(
                          title: const Text('Aktifkan Login dengan Fingerprint'),
                          secondary: const Icon(Icons.fingerprint),
                          value: user.fingerprintEnabled,
                          onChanged: (value) {
                            userController.updateFingerprintStatus(value);
                          },
                        ),
                        const Divider(),

                        // Switch untuk tema gelap
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return SwitchListTile(
                              title: const Text('Tema Gelap'),
                              secondary: const Icon(Icons.dark_mode),
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme(value);
                              },
                            );
                          }
                        ),

                        const Spacer(),
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
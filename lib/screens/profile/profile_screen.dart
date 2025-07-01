import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../theme/theme_provider.dart';
import '../../utils/user_session.dart';
import '../../widgets/nav_bar.dart';
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
    Future.microtask(() {
      final session = Get.find<UserSession>();
      final userId = session.userId.value;
      if (userId.isNotEmpty) {
        Provider.of<UserController>(context, listen: false).fetchUserData(userId);
      }
    });
  }

  void _logout() {
    final session = Get.find<UserSession>();
    final userId = session.userId.value; // Ambil userId SEBELUM session di-clear
    session.clear();
    // Kirim userId ke LoginScreen saat navigasi
    Get.offAll(() => const LoginScreen(), arguments: {'userId': userId});
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
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
                            user.name ?? '-',
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
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Aktifkan Login dengan Fingerprint'),
                      secondary: const Icon(Icons.fingerprint),
                      value: user.fingerprintEnabled,
                      onChanged: (value) async {
                        await userController.updateFingerprintStatus(user.uid, value);
                        await userController.fetchUserData(user.uid);
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Tema Gelap'),
                      secondary: const Icon(Icons.dark_mode),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) async{
                        themeProvider.toggleTheme(value);
                        await userController.fetchUserData(user.uid);
                      },
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
  }
}

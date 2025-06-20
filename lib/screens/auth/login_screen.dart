import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:growmee/controllers/auth_controller.dart';
import 'package:growmee/utils/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  // Tidak perlu instance AuthController di sini jika login manual ditangani di controllernya sendiri
  // Cukup panggil melalui Get.find() jika dibutuhkan

  // Dapatkan instance UserSession yang sudah ada
  final UserSession userSession = Get.find<UserSession>();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Tidak perlu Get.put() lagi di sini jika sudah di-inject di main.dart atau di route
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authController = Get.find<AuthController>();
      await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final userId = authController.userId;
      if (userId != null) {
        // Cukup set userId di session, sisanya akan diurus oleh UserSession
        userSession.setUserId(userId);
        Get.offAllNamed('/home');
      } else {
        throw Exception('ID pengguna tidak ditemukan.');
      }
    } catch (e) {
      setState(() {
        _error = 'Login gagal: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk login',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e) {
      setState(() {
        _error = 'Autentikasi biometrik gagal: $e';
      });
    }

    if (isAuthenticated) {
      // Jika berhasil, langsung navigasi. UserSession sudah berisi data yang benar.
      Get.offAllNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to GrowME',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.toNamed('/register'),
                  child: const Text('Daftar Akun'),
                ),
                const SizedBox(height: 24),

                Obx(() {
                  if (userSession.userId.isNotEmpty && userSession.isFingerprintEnabled.value) {
                    return ElevatedButton.icon(
                      onPressed: _loginWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Login dengan Fingerprint'),
                    );
                  } else {
                    return const SizedBox.shrink(); // Widget kosong
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:local_auth/local_auth.dart';
import 'package:growmee/controllers/auth_controller.dart';
import '../../services/database_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  final AuthController authController = Get.put(AuthController());

  bool _isLoading = false;
  String? _error;
  
@override
void initState() {
  super.initState();
  Get.put(UserController()); // Inject UserController
}

Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    final userId = authController.userId;
    final email = _emailController.text.trim();

    if (userId != null) {
      final userController = Get.find<UserController>();
      final exists = await userController.checkUserExists(userId);

      if (!exists) {
        await userController.saveInitialUserData(userId, email, ''); // kosongkan nama untuk sekarang
      }

      Get.offAllNamed('/home', arguments: {'userId': userId});
    } else {
      setState(() {
        _error = 'Login gagal: ID pengguna tidak ditemukan.';
      });
    }
  } catch (e) {
    setState(() {
      _error = 'Login gagal: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _loginWithBiometrics() async {
    bool isAuthenticated = false;

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Gunakan biometrik untuk login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Autentikasi biometrik gagal: $e';
      });
    }

    if (isAuthenticated) {
      final userId = authController.userId;
      if (userId != null) {
        Get.offAllNamed('/home', arguments: {'userId': userId});
      } else {
        setState(() {
          _error = 'Silakan login manual terlebih dahulu untuk mengaktifkan fingerprint.';
        });
      }
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
                ElevatedButton.icon(
                  onPressed: _loginWithBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Login dengan Fingerprint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

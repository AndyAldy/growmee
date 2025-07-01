import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:growmee/controllers/auth_controller.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:growmee/utils/user_session.dart';
import '../../theme/halus.dart';

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
  late final UserSession userSession;
  final UserController userController = Get.put(UserController());

  bool _isLoading = false;
  String? _error;

  bool _isCheckingBiometricStatus = true;
  bool _biometricOnlyLogin = false;
  bool _isBiometricAvailable = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    userSession = Get.put(UserSession(), permanent: true);
    _loadLastUserAndCheckBiometrics();
  }

  Future<void> _loadLastUserAndCheckBiometrics() async {
    final args = Get.arguments as Map<String, dynamic>?;
    String? userIdFromArgs = args?['userId'];

    if (userIdFromArgs != null) {
      _lastUserId = userIdFromArgs;
      await _checkBiometricStatus(_lastUserId!);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final lastUserIdFromPrefs = prefs.getString('last_user_id');

      if (lastUserIdFromPrefs != null) {
        _lastUserId = lastUserIdFromPrefs;
        await _checkBiometricStatus(_lastUserId!);
      } else {
        if (mounted) {
          setState(() {
            _isCheckingBiometricStatus = false;
          });
        }
      }
    }
  }

  Future<void> _saveLastUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_id', userId);
  }

  Future<void> _checkBiometricStatus(String userId) async {
    try {
      await userController.fetchUserData(userId);
      final isEnabled = userController.userModel?.fingerprintEnabled ?? false;

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isEnabled;
          _biometricOnlyLogin = isEnabled;
          _isCheckingBiometricStatus = false;
        });

        if (isEnabled) {
          _loginWithBiometrics();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingBiometricStatus = false;
          _biometricOnlyLogin = false;
          _isBiometricAvailable = false;
          _error = "Gagal memeriksa status biometrik.";
        });
      }
    }
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
        final exists = await userController.checkUserExists(userId);
        if (!exists) {
          await userController.saveInitialUserData(userId, email, '');
        }

        await userController.fetchUserData(userId);
        final name = userController.userModel?.name ?? '';
        userSession.setUserId(userId);
        userSession.setUserName(name);

        await _saveLastUserId(userId);

        Get.offAllNamed('/home', arguments: {'userId': userId});
      } else {
        setState(() {
          _error = 'Login gagal: ID pengguna tidak ditemukan.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login gagal: Email atau Password salah.';
      });
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    bool isAuthenticated = false;
    setState(() {
      _error = null;
    });

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Gunakan sidik jari untuk login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } else {
          setState(() {
          _error = 'Perangkat tidak mendukung biometrik.';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _error = 'Otentikasi biometrik gagal: $e';
      });
    }

    if (isAuthenticated) {
      final userId = _lastUserId;
      if (userId != null) {
        await userController.fetchUserData(userId);
        final name = userController.userModel?.name ?? '';
        userSession.setUserId(userId);
        userSession.setUserName(name);

        await _saveLastUserId(userId);

        Get.offAllNamed('/home', arguments: {'userId': userId});
      } else {
        setState(() {
          _error = 'ID Pengguna tidak ditemukan. Silakan login manual.';
          _biometricOnlyLogin = false;
        });
      }
    } else {
      if(mounted) {
        setState(() {
          _error = "Otentikasi dibatalkan.";
        });
      }
    }
  }

  Widget _buildStandardLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child:const Image(
              image: AssetImage('assets/img/Logo GrowME.png'),
              height: 50,
            ),
        ),

        const SizedBox(height: 80),
        const Text(
          'Welcome to GrowME',
          textAlign: TextAlign.center, // Center the text itself
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 140),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: CustomPaint(painter: SmoothLinePainter()),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? const CircularProgressIndicator(color: Color.fromARGB(255, 68, 255, 137))
              : const Text('Login'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Get.toNamed('/register'),
          child: const Text('Daftar Akun'),
        ),
        if (_isBiometricAvailable) ...[
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('ATAU'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loginWithBiometrics,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Login dengan Sidik Jari'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBiometricLoginView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Gunakan sidik jari Anda untuk masuk, ${userController.userModel?.name ?? 'Pengguna'}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 60),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton.icon(
          onPressed: _loginWithBiometrics,
          icon: const Icon(Icons.fingerprint),
          label: const Text('Login dengan Sidik Jari'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _biometricOnlyLogin = false;
              _error = null;
            });
          },
          child: const Text('Gunakan Email & Password'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use SafeArea to avoid UI being hidden by notches or status bars
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // REMOVED the Center widget from here
          child: _isCheckingBiometricStatus
              // Center only the loading indicator
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: _biometricOnlyLogin
                      ? _buildBiometricLoginView()
                      : _buildStandardLoginView(),
                ),
        ),
      ),
    );
  }
}

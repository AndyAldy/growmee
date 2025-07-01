import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../utils/user_session.dart';

class SplashScreen extends StatefulWidget {
  // Parameter untuk membedakan splash screen awal dan setelah login
  final bool isPostAuth;

  const SplashScreen({super.key, this.isPostAuth = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() {
    // Memberi jeda agar splash screen terlihat
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return; // Pastikan widget masih ada di tree

      if (widget.isPostAuth) {
        // Jika ini splash screen setelah login/register, langsung ke home
        Get.offAllNamed('/home');
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Jika sudah login, muat session dan ke home
          final session = Get.find<UserSession>();
          session.loadUserData(user.uid);
          Get.offAllNamed('/login');
        } else {
          Get.offAllNamed('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            Image.asset('assets/img/Logo GrowME.png', width: 150),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Sabar..',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}

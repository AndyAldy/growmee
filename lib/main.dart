import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growmee/screens/auth/login_screen.dart';
import 'package:growmee/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GrowME());
}

class GrowME extends StatelessWidget {
  const GrowME({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GrowMee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
// import semua screen yang perlu

Widget routeSettingsToWidget(String? name, dynamic args) {
  switch (name) {
    case '/':
      return const LoginScreen();

    case '/home':
      return const HomeScreen(); // Tidak perlu userId

    // Tambahkan case lain kalau perlu
    // case '/portfolio': return const PortfolioScreen();
    
    default:
      return const LoginScreen(); // fallback
  }
}

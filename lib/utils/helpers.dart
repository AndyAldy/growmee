import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';

Widget routeSettingsToWidget(String? name, dynamic args) {
  switch (name) {
    case '/':
      return const LoginScreen();

    case '/home':
      return const HomeScreen();

    default:
      return const LoginScreen();
  }
}

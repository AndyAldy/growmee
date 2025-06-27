import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/portfolio/Chart_screen.dart';
import 'screens/reksadana/joko_ai.dart';
import 'screens/profile/profile_screen.dart';

final List<GetPage> appPages = [
  GetPage(name: '/', page: () => const LoginScreen()),
  GetPage(name: '/register', page: () => const RegisterScreen()),

  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/live', page: () => ChartScreen()),
  GetPage(name: '/ai', page: () => ChatScreen()),
  GetPage(name: '/profile', page: () => const ProfileScreen()),
];

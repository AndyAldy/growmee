import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/portfolio/portfolio_screen.dart';
import 'screens/portfolio/portfolio_reksadana.dart';
import 'screens/portfolio/portfolio_sekuritas.dart';
import 'screens/reksadana/reksadana_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_risk_screen.dart';
import 'screens/history/history_pembelian.dart';
import 'screens/history/history_jual.dart';
import 'screens/history/history_pengalihan.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<GetPage> appPages = [
  GetPage(name: '/', page: () => const LoginScreen()),
  GetPage(name: '/register', page: () => const RegisterScreen()),

  // HomeScreen menerima argumen userId dari Get.arguments
  GetPage(
    name: '/home',
    page: () => HomeScreen(userId: Get.arguments['userId']),
  ),

  GetPage(
    name: '/portfolio',
    page: () => PortfolioScreen(userId: Get.arguments['userId']),
  ),

  GetPage(
    name: '/portfolio/reksadana',
    page: () => PortfolioReksadanaScreen(userId: Get.arguments['userId']),
  ),

  GetPage(
    name: '/portfolio/sekuritas',
    page: () => PortfolioSekuritasScreen(userId: Get.arguments['userId']),
  ),

  GetPage(name: '/reksadana', page: () => const ReksadanaScreen()),
  GetPage(name: '/profile', page: () => const ProfileScreen()),
  GetPage(name: '/profilerisk', page: () => const ProfileRiskScreen()),
  GetPage(name: '/history/pembelian', page: () => HistoryPembelianScreen()),
  GetPage(name: '/history/jual', page: () => const HistoryJualScreen()),
  GetPage(name: '/history/pengalihan', page: () => HistoryPengalihanScreen()),
];

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

final List<GetPage> appPages = [
  GetPage(name: '/', page: () => const LoginScreen()),
  GetPage(name: '/register', page: () => const RegisterScreen()),

  // Halaman yang sudah pakai UserSession, tidak perlu argumen lagi
  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/portfolio', page: () => const PortfolioScreen()),
  GetPage(name: '/portfolio/reksadana', page: () => PortfolioReksadanaScreen()),
  GetPage(name: '/portfolio/sekuritas', page: () => PortfolioSekuritasScreen()),
  GetPage(name: '/reksadana', page: () => ReksadanaScreen()),
  GetPage(name: '/profile', page: () => const ProfileScreen()),
  GetPage(name: '/profilerisk', page: () => const ProfileRiskScreen()),

  // Riwayat juga ambil userId dari UserSession
  GetPage(name: '/history/pembelian', page: () => HistoryPembelianScreen()),
  GetPage(name: '/history/jual', page: () => const HistoryJualScreen()),
  GetPage(name: '/history/pengalihan', page: () => HistoryPengalihanScreen()),
];

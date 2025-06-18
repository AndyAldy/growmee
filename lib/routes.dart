import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/portfolio/Chart_screen.dart';
import 'screens/reksadana/Reksaedu.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/history/history_pembelian.dart';
import 'screens/history/history_jual.dart';
import 'screens/history/history_pengalihan.dart';

final List<GetPage> appPages = [
  GetPage(name: '/', page: () => const LoginScreen()),
  GetPage(name: '/register', page: () => const RegisterScreen()),

  // Halaman yang sudah pakai UserSession, tidak perlu argumen lagi
  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/live', page: () => ChartScreen()),
  GetPage(name: '/edu', page: () => ReksadanaEduScreen()),
  GetPage(name: '/profile', page: () => const ProfileScreen()),

  // Riwayat juga ambil userId dari UserSession
  GetPage(name: '/history/pembelian', page: () => HistoryPembelianScreen()),
  GetPage(name: '/history/jual', page: () => const HistoryJualScreen()),
  GetPage(name: '/history/pengalihan', page: () => HistoryPengalihanScreen()),
];

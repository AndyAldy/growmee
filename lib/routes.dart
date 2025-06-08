import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/reksadana/reksadana_screen.dart';
import 'screens/portfolio/portfolio_screen.dart';
import 'screens/portfolio/portfolio_reksadana.dart';
import 'screens/portfolio/portfolio_sekuritas.dart';
import 'screens/reksadana/reksadana_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_risk_screen.dart';
import 'screens/history/history_pembelian.dart';
import 'screens/history/history_jual.dart';
import 'screens/history/history_pengalihan.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/home': (context) => const HomeScreen(),
  '/portfolio': (context) => const PortfolioScreen(userId: '',),
  '/portfolio/reksadana': (context) => PortfolioReksadanaScreen(userId: '',),
  '/portfolio/sekuritas': (context) => PortfolioSekuritasScreen(userId: '',),
  '/reksadana': (context) => const ReksadanaScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/profile/risk': (context) => const ProfileRiskScreen(),
  '/history/pembelian': (context) => HistoryPembelianScreen(),
  '/history/jual': (context) => const HistoryJualScreen(),
  '/history/pengalihan': (context) => HistoryPengalihanScreen(),
};
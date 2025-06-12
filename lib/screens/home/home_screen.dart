import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growmee/controllers/auth_controller.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/reksadana_card.dart';
import '../../theme/theme_provider.dart';
import '../transaction/topup_screen.dart';
import '../transaction/beli_screen.dart';
import '../transaction/jual_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required userId});

@override
Widget build(BuildContext context) {
  final themeProvider = AppTheme(context);
  final isDark = themeProvider.isDarkMode;
  final userId = Get.find<AuthController>().userId;
  print('User ID: $userId');
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Investasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Halo, Investor 👋',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Total Investasi Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Investasi Anda',
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rp 12.500.000',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Aksi cepat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickAction(
                icon: Icons.add_circle,
                label: 'Top Up',
                isDark: isDark,
                onTap: () => Get.to(() => const TopUpScreen()),
              ),
              _QuickAction(
                icon: Icons.shopping_cart,
                label: 'Beli',
                isDark: isDark,
                onTap: () => Get.to(() => const BeliScreen()),
              ),
              _QuickAction(
                icon: Icons.trending_down,
                label: 'Jual',
                isDark: isDark,
                onTap: () => Get.to(() => const JualScreen()),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Rekomendasi Reksadana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          // Card Horizontal
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                ReksadanaCard(
                  title: 'Danamas Stabil',
                  risk: 'Rendah',
                  returnPercent: 4.25,
                  amount: 500000,
                ),
                SizedBox(width: 12),
                ReksadanaCard(
                  title: 'Saham Hebat',
                  risk: 'Tinggi',
                  returnPercent: 15.2,
                  amount: 250000,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ⬅️ Navigasi saat dipencet
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: isDark ? Colors.grey[700] : Colors.white,
            child: Icon(icon, color: Colors.blueAccent, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/nav_bar.dart';

class ReksadanaEduScreen extends StatefulWidget {
  const ReksadanaEduScreen({super.key});

  @override
  State<ReksadanaEduScreen> createState() => _ReksadanaEduScreenState();
}

class _ReksadanaEduScreenState extends State<ReksadanaEduScreen> {
  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Edukasi Reksa Dana',
          style: TextStyle(color: isDark ? Colors.white : Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFE0F7FA),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _EduCard(
          title: 'Apa Itu Reksa Dana?',
          content:
              'Reksa dana adalah wadah investasi yang dikelola oleh manajer investasi, menggabungkan dana dari banyak investor untuk diinvestasikan ke dalam portofolio efek.',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _EduCard(
          title: 'Jenis-Jenis Reksa Dana',
          content:
              'Ada beberapa jenis reksa dana seperti pasar uang, pendapatan tetap (obligasi), campuran, dan saham. Masing-masing memiliki profil risiko dan imbal hasil yang berbeda.',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _EduCard(
          title: 'Keuntungan Investasi Reksa Dana',
          content:
              'Diversifikasi otomatis, dikelola profesional, modal awal terjangkau, dan bisa dibeli/jual dengan mudah melalui aplikasi.',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _EduCard(
          title: 'Risiko Reksa Dana',
          content:
              'Nilai investasi dapat naik turun tergantung kondisi pasar. Pilihlah jenis reksa dana sesuai profil risiko kamu.',
          isDark: isDark,
        ),
      ],
    ),
    bottomNavigationBar: const NavBar(currentIndex: 2),
  );
}

}

class _EduCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _EduCard({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- 1. Import package
import '../../widgets/nav_bar.dart';

class ReksadanaEduScreen extends StatefulWidget {
  const ReksadanaEduScreen({super.key});

  @override
  State<ReksadanaEduScreen> createState() => _ReksadanaEduScreenState();
}

class _ReksadanaEduScreenState extends State<ReksadanaEduScreen> {
  // 2. Buat fungsi untuk membuka URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Jika gagal, bisa tampilkan snackbar atau pesan error
      Get.snackbar('Error', 'Tidak dapat membuka link: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Edukasi Reksa Dana',
          style: TextStyle(color: Colors.white), // Disederhanakan, karena background biru, teks selalu putih
        ),
        leading: IconButton(
          // 5. Warna icon disamakan agar konsisten
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
          const SizedBox(height: 16),
          
          // 3. Card baru untuk link edukasi eksternal
          _EduLinkCard(
            title: 'Baca Selengkapnya',
            isDark: isDark,
            links: {
              'OJK - Otoritas Jasa Keuangan': 'https://sikapiuangmu.ojk.go.id/FrontEnd/CMS/Category/34',
              'IDX - Bursa Efek Indonesia': 'https://www.idx.co.id/id/produk/reksa-dana',
              'CNBC Indonesia - Panduan Pemula': 'https://www.cnbcindonesia.com/investment/20231109151528-23-487779/panduan-lengkap-investasi-reksa-dana-untuk-pemula',
              'Bibit - Blog Edukasi': 'https://blog.bibit.id/belajar-investasi/reksadana-adalah',
            },
            launchURL: _launchURL, // Mengoper fungsi _launchURL
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

// 4. Widget baru yang dibuat khusus untuk menampilkan link
class _EduLinkCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final Map<String, String> links;
  final Function(String) launchURL;

  const _EduLinkCard({
    required this.title,
    required this.isDark,
    required this.links,
    required this.launchURL,
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
          const SizedBox(height: 12),
          // Membuat list link dari Map
          ...links.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  text: '• ${entry.key}',
                  style: TextStyle(
                    color: isDark ? Colors.blue[300] : Colors.blue[700],
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(entry.value);
                    },
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
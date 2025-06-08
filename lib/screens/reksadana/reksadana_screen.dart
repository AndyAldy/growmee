import 'package:flutter/material.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/reksadana_card.dart';

class ReksadanaScreen extends StatelessWidget {
  const ReksadanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reksa Dana'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE0F7FA), // biru langit
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ReksadanaCard(
            title: 'Danamas Stabil',
            risk: 'Rendah',
            returnPercent: 4.25,
            amount: 500000,
          ),
          SizedBox(height: 16),
          ReksadanaCard(
            title: 'Saham Hebat',
            risk: 'Tinggi',
            returnPercent: 15.2,
            amount: 250000,
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}

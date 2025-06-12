import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/reksadana_card.dart';
import '../../screens/home/home_screen.dart';
import '../../utils/user_session.dart';

class ReksadanaScreen extends StatelessWidget {
  ReksadanaScreen({super.key});

  final userId = Get.find<UserSession>().userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reksa Dana'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => HomeScreen());
          },
        ),
      ),
      backgroundColor: const Color(0xFFE0F7FA),
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
      bottomNavigationBar: NavBar(currentIndex: 2, userId: userId.value),
    );
  }
}

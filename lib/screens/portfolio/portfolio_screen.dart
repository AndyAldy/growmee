import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growmee/screens/home/home_screen.dart';
import '../../utils/user_session.dart';
import 'portfolio_reksadana.dart';
import 'portfolio_sekuritas.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = Get.find<UserSession>();
    final userId = session.userId.value;

    final List<Widget> pages = [
      PortfolioReksadanaScreen(),
      PortfolioSekuritasScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portofolio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => HomeScreen());
          },
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Reksadana'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Sekuritas'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

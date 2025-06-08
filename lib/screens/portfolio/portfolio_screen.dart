import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'portfolio_reksadana.dart';
import 'portfolio_sekuritas.dart';

class PortfolioScreen extends StatefulWidget {
  final String userId;
  const PortfolioScreen({super.key, required this.userId});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PortfolioReksadanaScreen(userId: widget.userId),
      PortfolioSekuritasScreen(userId: widget.userId),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio')),
      body: _pages[_selectedIndex],
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

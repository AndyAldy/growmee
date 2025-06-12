import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final String userId;

  const NavBar({super.key, required this.currentIndex, required this.userId});

  void _onTap(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/home', arguments: userId);
        break;
      case 1:
        Get.offAllNamed('/portfolio', arguments: userId);
        break;
      case 2:
        Get.offAllNamed('/reksadana', arguments: userId);
        break;
      case 3:
      
        Get.offAllNamed('/profile', arguments: userId, );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portofolio'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Reksa Dana'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}

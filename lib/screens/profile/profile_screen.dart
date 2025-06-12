import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import 'profile_risk_screen.dart';
import '../../screens/home/home_screen.dart';
import 'package:growmee/utils/user_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
@override
void initState() {
  super.initState();
  Future.microtask(() {
    final session = Get.find<UserSession>();
    final userId = session.userId.value;
    Provider.of<UserController>(context, listen: false)
        .fetchUserData(userId);
  });
}


  Widget _buildRiskTag(String? riskLevel) {
    Color bgColor;
    String label;

    switch (riskLevel) {
      case 'Tinggi':
        bgColor = Colors.redAccent;
        label = '🐅Agresif';
        break;
      case 'Sedang':
        bgColor = Colors.orangeAccent;
        label = '🦉Moderat';
        break;
      case 'Rendah':
        bgColor = Colors.green;
        label = '🦌Konservatif';
        break;
      default:
        bgColor = Colors.grey;
        label = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final user = userController.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    final session = Get.find<UserSession>();
    Get.to(() => HomeScreen());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama Pengguna',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(user.name ?? '-',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  Text('Email',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(user.email,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),

                  Text('Profil Risiko',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRiskTag(user.riskLevel),
                      const SizedBox(width: 12),
                      Text(
                        user.riskLevel ?? '-',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileRiskScreen()),
                        );
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text('Ubah Profil Risiko'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

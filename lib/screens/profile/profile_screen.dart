import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import 'profile_risk_screen.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final user = userController.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'),
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${user.name ?? '-'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  Text('Email: ${user.email ?? '-'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileRiskScreen()),
                      );
                    },
                    child: const Text('Ubah Profil Risiko'),
                  ),
                ],
              ),
      ),
    );
  }
}
